from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

import duckdb

from codex_profile.adapters.usage import AdaptedRolloutRecord, UsageFields, UsageState
from codex_profile.reporting import TokenUsage


COLLECTOR_WRITER = "collector"


@dataclass(frozen=True)
class IngestCounts:
    raw_inserted: int = 0
    normalized_inserted: int = 0
    diagnostics_inserted: int = 0

    def plus(self, other: "IngestCounts") -> "IngestCounts":
        return IngestCounts(
            raw_inserted=self.raw_inserted + other.raw_inserted,
            normalized_inserted=self.normalized_inserted + other.normalized_inserted,
            diagnostics_inserted=self.diagnostics_inserted + other.diagnostics_inserted,
        )


class ProfileStorage:
    def __init__(
        self,
        database: Path,
        *,
        writer_id: str = COLLECTOR_WRITER,
        readonly: bool = False,
    ) -> None:
        if not readonly and writer_id != COLLECTOR_WRITER:
            raise PermissionError("DuckDB writes are restricted to the collector")
        self.database = database.expanduser()
        self.readonly = readonly
        if readonly:
            if not self.database.exists():
                raise FileNotFoundError(f"missing database: {self.database}")
            self.connection = duckdb.connect(str(self.database), read_only=True)
        else:
            self.database.parent.mkdir(parents=True, exist_ok=True)
            self.connection = duckdb.connect(str(self.database))
            self.init_schema()

    def close(self) -> None:
        self.connection.close()

    def init_schema(self) -> None:
        self._ensure_writer()
        self.connection.execute(
            """
            CREATE TABLE IF NOT EXISTS collector_sources (
              source_id TEXT NOT NULL,
              source_generation UBIGINT NOT NULL,
              source_kind TEXT NOT NULL,
              source_path TEXT NOT NULL,
              first_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              PRIMARY KEY (source_id, source_generation)
            )
            """
        )
        self.connection.execute(
            """
            CREATE TABLE IF NOT EXISTS collector_watermarks (
              source_id TEXT NOT NULL,
              source_generation UBIGINT NOT NULL,
              next_offset UBIGINT NOT NULL,
              updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              PRIMARY KEY (source_id, source_generation)
            )
            """
        )
        self.connection.execute(
            """
            CREATE TABLE IF NOT EXISTS raw_rollout_observations (
              source_id TEXT NOT NULL,
              source_generation UBIGINT NOT NULL,
              source_offset UBIGINT NOT NULL,
              event_timestamp TEXT,
              event_kind TEXT NOT NULL,
              raw_byte_count UBIGINT NOT NULL,
              payload_digest TEXT NOT NULL,
              schema_name TEXT,
              schema_version TEXT,
              token_observation_mode TEXT,
              reported_input_tokens BIGINT,
              cached_input_tokens BIGINT,
              fresh_input_tokens BIGINT,
              output_tokens BIGINT,
              reasoning_output_tokens BIGINT,
              total_tokens BIGINT,
              cumulative_reported_input_tokens BIGINT,
              cumulative_cached_input_tokens BIGINT,
              cumulative_fresh_input_tokens BIGINT,
              cumulative_output_tokens BIGINT,
              cumulative_reasoning_output_tokens BIGINT,
              cumulative_total_tokens BIGINT,
              PRIMARY KEY (source_id, source_generation, source_offset)
            )
            """
        )
        self.connection.execute(
            """
            CREATE TABLE IF NOT EXISTS normalized_usage_observations (
              source_id TEXT NOT NULL,
              source_generation UBIGINT NOT NULL,
              source_offset UBIGINT NOT NULL,
              event_timestamp TEXT NOT NULL,
              event_kind TEXT NOT NULL,
              normalization_method TEXT NOT NULL,
              usage_observation_index UBIGINT NOT NULL,
              reported_input_tokens UBIGINT NOT NULL,
              cached_input_tokens UBIGINT NOT NULL,
              fresh_input_tokens UBIGINT NOT NULL,
              output_tokens UBIGINT NOT NULL,
              reasoning_output_tokens UBIGINT NOT NULL,
              total_tokens UBIGINT NOT NULL,
              PRIMARY KEY (source_id, source_generation, source_offset)
            )
            """
        )
        self.connection.execute(
            """
            CREATE TABLE IF NOT EXISTS collector_diagnostics (
              diagnostic_id TEXT NOT NULL,
              source_id TEXT NOT NULL,
              source_generation UBIGINT NOT NULL,
              source_offset UBIGINT NOT NULL,
              code TEXT NOT NULL,
              severity TEXT NOT NULL,
              message TEXT NOT NULL,
              created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              PRIMARY KEY (diagnostic_id)
            )
            """
        )

    def get_watermark(self, source_id: str, source_generation: int) -> int:
        row = self.connection.execute(
            """
            SELECT next_offset
            FROM collector_watermarks
            WHERE source_id = ? AND source_generation = ?
            """,
            [source_id, source_generation],
        ).fetchone()
        return int(row[0]) if row else 0

    def load_usage_state(self, source_id: str, source_generation: int) -> UsageState:
        cumulative = self.connection.execute(
            """
            SELECT
              cumulative_total_tokens,
              cumulative_reported_input_tokens,
              cumulative_cached_input_tokens,
              cumulative_output_tokens,
              cumulative_reasoning_output_tokens
            FROM raw_rollout_observations
            WHERE source_id = ?
              AND source_generation = ?
              AND cumulative_total_tokens IS NOT NULL
            ORDER BY source_offset DESC
            LIMIT 1
            """,
            [source_id, source_generation],
        ).fetchone()
        started = self.connection.execute(
            """
            SELECT count(*)
            FROM raw_rollout_observations
            WHERE source_id = ?
              AND source_generation = ?
              AND lower(event_kind) SIMILAR TO '%(session_meta|session_start)%'
            """,
            [source_id, source_generation],
        ).fetchone()
        previous = None
        if cumulative:
            previous = TokenUsage(
                total=int(cumulative[0]),
                input=int(cumulative[1]),
                cached_input=int(cumulative[2]),
                output=int(cumulative[3]),
                reasoning=int(cumulative[4]),
            )
        return UsageState(previous_cumulative=previous, session_started=bool(started and started[0]))

    def admit(self, adapted: AdaptedRolloutRecord, *, fail_after_raw: bool = False) -> IngestCounts:
        self._ensure_writer()
        record = adapted.raw.record
        exists = self.connection.execute(
            """
            SELECT 1
            FROM raw_rollout_observations
            WHERE source_id = ? AND source_generation = ? AND source_offset = ?
            """,
            [record.source_id, record.source_generation, record.source_offset],
        ).fetchone()
        if exists:
            self._advance_watermark(record.source_id, record.source_generation, record.next_offset)
            return IngestCounts()

        self.connection.execute("BEGIN TRANSACTION")
        try:
            self.connection.execute(
                """
                INSERT INTO collector_sources (
                  source_id, source_generation, source_kind, source_path
                )
                VALUES (?, ?, 'rollout', ?)
                ON CONFLICT (source_id, source_generation)
                DO UPDATE SET last_seen_at = now(), source_path = excluded.source_path
                """,
                [record.source_id, record.source_generation, str(record.path)],
            )
            self._insert_raw(adapted)
            if fail_after_raw:
                raise RuntimeError("simulated collector transaction failure")
            normalized_inserted = 0
            if adapted.normalized is not None:
                self._insert_normalized(adapted)
                normalized_inserted = 1
            for diagnostic in adapted.diagnostics:
                self.connection.execute(
                    """
                    INSERT INTO collector_diagnostics (
                      diagnostic_id,
                      source_id,
                      source_generation,
                      source_offset,
                      code,
                      severity,
                      message
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    [
                        f"{record.source_id}:{record.source_generation}:{record.source_offset}:{diagnostic.code}",
                        record.source_id,
                        record.source_generation,
                        record.source_offset,
                        diagnostic.code,
                        "strict" if diagnostic.strict else "advisory",
                        diagnostic.message,
                    ],
                )
            self._advance_watermark(record.source_id, record.source_generation, record.next_offset)
            self.connection.execute("COMMIT")
        except Exception:
            self.connection.execute("ROLLBACK")
            raise
        return IngestCounts(1, normalized_inserted, len(adapted.diagnostics))

    def _advance_watermark(self, source_id: str, source_generation: int, next_offset: int) -> None:
        self._ensure_writer()
        self.connection.execute(
            """
            INSERT INTO collector_watermarks (source_id, source_generation, next_offset)
            VALUES (?, ?, ?)
            ON CONFLICT (source_id, source_generation)
            DO UPDATE SET
              next_offset = greatest(collector_watermarks.next_offset, excluded.next_offset),
              updated_at = now()
            """,
            [source_id, source_generation, next_offset],
        )

    def _insert_raw(self, adapted: AdaptedRolloutRecord) -> None:
        self._ensure_writer()
        raw = adapted.raw
        record = raw.record
        token = _field_values(raw.token_fields)
        cumulative = _field_values(raw.cumulative_fields)
        self.connection.execute(
            """
            INSERT INTO raw_rollout_observations (
              source_id,
              source_generation,
              source_offset,
              event_timestamp,
              event_kind,
              raw_byte_count,
              payload_digest,
              schema_name,
              schema_version,
              token_observation_mode,
              reported_input_tokens,
              cached_input_tokens,
              fresh_input_tokens,
              output_tokens,
              reasoning_output_tokens,
              total_tokens,
              cumulative_reported_input_tokens,
              cumulative_cached_input_tokens,
              cumulative_fresh_input_tokens,
              cumulative_output_tokens,
              cumulative_reasoning_output_tokens,
              cumulative_total_tokens
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                record.source_id,
                record.source_generation,
                record.source_offset,
                None if raw.event_timestamp is None else raw.event_timestamp.isoformat(),
                raw.event_kind,
                record.raw_byte_count,
                record.payload_digest,
                raw.schema_name,
                raw.schema_version,
                raw.token_observation_mode,
                *token,
                *cumulative,
            ],
        )

    def _insert_normalized(self, adapted: AdaptedRolloutRecord) -> None:
        self._ensure_writer()
        assert adapted.normalized is not None
        normalized = adapted.normalized
        record = normalized.record
        fields = normalized.fields
        self.connection.execute(
            """
            INSERT INTO normalized_usage_observations (
              source_id,
              source_generation,
              source_offset,
              event_timestamp,
              event_kind,
              normalization_method,
              usage_observation_index,
              reported_input_tokens,
              cached_input_tokens,
              fresh_input_tokens,
              output_tokens,
              reasoning_output_tokens,
              total_tokens
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                record.source_id,
                record.source_generation,
                record.source_offset,
                normalized.event_timestamp.isoformat(),
                normalized.event_kind,
                normalized.method,
                record.source_offset,
                fields.reported_input_tokens,
                fields.cached_input_tokens,
                fields.fresh_input_tokens,
                fields.output_tokens,
                fields.reasoning_output_tokens,
                fields.total_tokens,
            ],
        )

    def table_count(self, table: str) -> int:
        if table not in {
            "collector_sources",
            "collector_watermarks",
            "raw_rollout_observations",
            "normalized_usage_observations",
            "collector_diagnostics",
        }:
            raise ValueError(f"unknown table: {table}")
        row = self.connection.execute(f"SELECT count(*) FROM {table}").fetchone()
        return int(row[0])

    def summary(self) -> dict[str, Any]:
        totals = self.connection.execute(
            """
            SELECT
              count(*),
              coalesce(sum(total_tokens), 0),
              coalesce(sum(reported_input_tokens), 0),
              coalesce(sum(cached_input_tokens), 0),
              coalesce(sum(fresh_input_tokens), 0),
              coalesce(sum(output_tokens), 0),
              coalesce(sum(reasoning_output_tokens), 0)
            FROM normalized_usage_observations
            """
        ).fetchone()
        diagnostics = self.connection.execute(
            """
            SELECT code, count(*)
            FROM collector_diagnostics
            GROUP BY code
            ORDER BY code
            """
        ).fetchall()
        return {
            "raw_observations": self.table_count("raw_rollout_observations"),
            "normalized_usage_observations": int(totals[0]),
            "tokens": {
                "total": int(totals[1]),
                "reported_input": int(totals[2]),
                "cached_input": int(totals[3]),
                "fresh_input": int(totals[4]),
                "output": int(totals[5]),
                "reasoning_output": int(totals[6]),
            },
            "diagnostics": {str(code): int(count) for code, count in diagnostics},
        }

    def _ensure_writer(self) -> None:
        if self.readonly:
            raise PermissionError("read-only storage handle cannot mutate DuckDB")


def _field_values(fields: UsageFields | None) -> list[int | None]:
    if fields is None:
        return [None, None, None, None, None, None]
    values = asdict(fields)
    return [
        values["reported_input_tokens"],
        values["cached_input_tokens"],
        values["fresh_input_tokens"],
        values["output_tokens"],
        values["reasoning_output_tokens"],
        values["total_tokens"],
    ]
