from __future__ import annotations

import hashlib
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Sequence

import duckdb

from codex_profile.adapters.usage import (
    ADAPTER_DIGEST,
    ADAPTER_ID,
    ADAPTER_VERSION,
    AdaptedRolloutRecord,
    UsageFields,
    UsageState,
)
from codex_profile.reporting import TokenUsage
from codex_profile.sources.rollout import RolloutRecord, source_incarnation, stable_source_id


COLLECTOR_WRITER = "collector"
ANCHOR_BYTE_WINDOW = 4096


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


@dataclass(frozen=True)
class SourceCheckpoint:
    source_id: str
    source_generation: int
    next_offset: int
    anchor_start: int
    anchor_end: int
    anchor_digest: str


@dataclass(frozen=True)
class ResolvedSource:
    source_id: str
    source_generation: int
    start_offset: int
    state: UsageState


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
              source_identity TEXT,
              last_size_bytes UBIGINT,
              first_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              PRIMARY KEY (source_id, source_generation)
            )
            """
        )
        self._ensure_column("collector_sources", "source_identity", "TEXT")
        self._ensure_column("collector_sources", "last_size_bytes", "UBIGINT")
        self.connection.execute(
            """
            CREATE TABLE IF NOT EXISTS collector_watermarks (
              source_id TEXT NOT NULL,
              source_generation UBIGINT NOT NULL,
              next_offset UBIGINT NOT NULL,
              anchor_start UBIGINT NOT NULL,
              anchor_end UBIGINT NOT NULL,
              anchor_digest TEXT NOT NULL,
              updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              PRIMARY KEY (source_id, source_generation)
            )
            """
        )
        self._ensure_column("collector_watermarks", "anchor_start", "UBIGINT")
        self._ensure_column("collector_watermarks", "anchor_end", "UBIGINT")
        self._ensure_column("collector_watermarks", "anchor_digest", "TEXT")
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
        self._ensure_normalized_usage_schema()
        self.connection.execute(
            """
            CREATE TABLE IF NOT EXISTS collector_diagnostics (
              diagnostic_id TEXT NOT NULL,
              source_id TEXT NOT NULL,
              source_generation UBIGINT NOT NULL,
              source_offset UBIGINT NOT NULL,
              adapter_id TEXT NOT NULL,
              adapter_version TEXT NOT NULL,
              adapter_digest TEXT NOT NULL,
              code TEXT NOT NULL,
              diagnostic_scope TEXT NOT NULL,
              diagnostic_ordinal UBIGINT NOT NULL,
              severity TEXT NOT NULL,
              message TEXT NOT NULL,
              created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
              PRIMARY KEY (diagnostic_id)
            )
            """
        )
        self._ensure_column("collector_diagnostics", "adapter_id", f"TEXT DEFAULT '{ADAPTER_ID}'")
        self._ensure_column("collector_diagnostics", "adapter_version", f"TEXT DEFAULT '{ADAPTER_VERSION}'")
        self._ensure_column("collector_diagnostics", "adapter_digest", f"TEXT DEFAULT '{ADAPTER_DIGEST}'")
        self._ensure_column("collector_diagnostics", "diagnostic_scope", "TEXT DEFAULT 'record'")
        self._ensure_column("collector_diagnostics", "diagnostic_ordinal", "UBIGINT DEFAULT 0")

    def resolve_source(self, path: Path) -> ResolvedSource:
        source_id = stable_source_id(path)
        generation, start_offset = self._resolve_source_generation_and_offset(path, source_id)
        return ResolvedSource(
            source_id=source_id,
            source_generation=generation,
            start_offset=start_offset,
            state=self.load_usage_state(source_id, generation),
        )

    def resolve_source_generation(self, path: Path, source_id: str) -> int:
        generation, _ = self._resolve_source_generation_and_offset(path, source_id)
        return generation

    def _resolve_source_generation_and_offset(self, path: Path, source_id: str) -> tuple[int, int]:
        incarnation = source_incarnation(path)
        row = self.connection.execute(
            """
            SELECT source_generation, source_identity
            FROM collector_sources
            WHERE source_id = ?
            ORDER BY source_generation DESC
            LIMIT 1
            """,
            [source_id],
        ).fetchone()
        if row is None:
            return 0, 0

        generation = int(row[0])
        previous_identity = row[1]
        checkpoint = self.get_source_checkpoint(source_id, generation)
        if checkpoint is None:
            if self._watermark_exists(source_id, generation):
                return generation + 1, 0
            return generation, 0
        if previous_identity is not None and str(previous_identity) != incarnation.identity:
            return generation + 1, 0
        if incarnation.size < checkpoint.next_offset:
            return generation + 1, 0
        if not self._checkpoint_anchor_matches(path, checkpoint):
            return generation + 1, 0
        return generation, checkpoint.next_offset

    def get_watermark(self, source_id: str, source_generation: int) -> int:
        checkpoint = self.get_source_checkpoint(source_id, source_generation)
        return checkpoint.next_offset if checkpoint else 0

    def get_source_checkpoint(self, source_id: str, source_generation: int) -> SourceCheckpoint | None:
        row = self.connection.execute(
            """
            SELECT next_offset, anchor_start, anchor_end, anchor_digest
            FROM collector_watermarks
            WHERE source_id = ? AND source_generation = ?
            """,
            [source_id, source_generation],
        ).fetchone()
        if row is None:
            return None
        next_offset = int(row[0])
        anchor_start, anchor_end, anchor_digest = row[1], row[2], row[3]
        if anchor_start is None or anchor_end is None or anchor_digest is None:
            return None
        return SourceCheckpoint(
            source_id=source_id,
            source_generation=source_generation,
            next_offset=next_offset,
            anchor_start=int(anchor_start),
            anchor_end=int(anchor_end),
            anchor_digest=str(anchor_digest),
        )

    def _watermark_exists(self, source_id: str, source_generation: int) -> bool:
        row = self.connection.execute(
            """
            SELECT 1
            FROM collector_watermarks
            WHERE source_id = ? AND source_generation = ?
            """,
            [source_id, source_generation],
        ).fetchone()
        return row is not None

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
            self._advance_watermark(record)
            return IngestCounts()

        self.connection.execute("BEGIN TRANSACTION")
        try:
            incarnation = source_incarnation(record.path)
            self.connection.execute(
                """
                INSERT INTO collector_sources (
                  source_id, source_generation, source_kind, source_path, source_identity, last_size_bytes
                )
                VALUES (?, ?, 'rollout', ?, ?, ?)
                ON CONFLICT (source_id, source_generation)
                DO UPDATE SET
                  last_seen_at = now(),
                  source_path = excluded.source_path,
                  source_identity = excluded.source_identity,
                  last_size_bytes = excluded.last_size_bytes
                """,
                [
                    record.source_id,
                    record.source_generation,
                    str(record.path),
                    incarnation.identity,
                    incarnation.size,
                ],
            )
            self._insert_raw(adapted)
            if fail_after_raw:
                raise RuntimeError("simulated collector transaction failure")
            normalized_inserted = 0
            if adapted.normalized is not None:
                self._insert_normalized(adapted)
                normalized_inserted = 1
            for ordinal, diagnostic in enumerate(adapted.diagnostics):
                self.connection.execute(
                    """
                    INSERT INTO collector_diagnostics (
                      diagnostic_id,
                      source_id,
                      source_generation,
                      source_offset,
                      adapter_id,
                      adapter_version,
                      adapter_digest,
                      code,
                      diagnostic_scope,
                      diagnostic_ordinal,
                      severity,
                      message
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    [
                        (
                            f"{record.source_id}:{record.source_generation}:{record.source_offset}:"
                            f"{ADAPTER_ID}:{ADAPTER_VERSION}:{diagnostic.code}:{ordinal}:{diagnostic.scope}"
                        ),
                        record.source_id,
                        record.source_generation,
                        record.source_offset,
                        ADAPTER_ID,
                        ADAPTER_VERSION,
                        ADAPTER_DIGEST,
                        diagnostic.code,
                        diagnostic.scope,
                        ordinal,
                        "strict" if diagnostic.strict else "advisory",
                        diagnostic.message,
                    ],
                )
            self._advance_watermark(record)
            self.connection.execute("COMMIT")
        except Exception:
            self.connection.execute("ROLLBACK")
            raise
        return IngestCounts(1, normalized_inserted, len(adapted.diagnostics))

    def _advance_watermark(self, record: RolloutRecord) -> None:
        self._ensure_writer()
        checkpoint = _source_checkpoint(
            record.path,
            record.source_id,
            record.source_generation,
            record.next_offset,
        )
        self.connection.execute(
            """
            INSERT INTO collector_watermarks (
              source_id,
              source_generation,
              next_offset,
              anchor_start,
              anchor_end,
              anchor_digest
            )
            VALUES (?, ?, ?, ?, ?, ?)
            ON CONFLICT (source_id, source_generation)
            DO UPDATE SET
              next_offset = greatest(collector_watermarks.next_offset, excluded.next_offset),
              anchor_start = CASE
                WHEN excluded.next_offset >= collector_watermarks.next_offset THEN excluded.anchor_start
                ELSE collector_watermarks.anchor_start
              END,
              anchor_end = CASE
                WHEN excluded.next_offset >= collector_watermarks.next_offset THEN excluded.anchor_end
                ELSE collector_watermarks.anchor_end
              END,
              anchor_digest = CASE
                WHEN excluded.next_offset >= collector_watermarks.next_offset THEN excluded.anchor_digest
                ELSE collector_watermarks.anchor_digest
              END,
              updated_at = now()
            """,
            [
                checkpoint.source_id,
                checkpoint.source_generation,
                checkpoint.next_offset,
                checkpoint.anchor_start,
                checkpoint.anchor_end,
                checkpoint.anchor_digest,
            ],
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
              adapter_id,
              adapter_version,
              adapter_digest,
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
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                record.source_id,
                record.source_generation,
                record.source_offset,
                ADAPTER_ID,
                ADAPTER_VERSION,
                ADAPTER_DIGEST,
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

    def strict_diagnostic_count(self, active_sources: Sequence[tuple[str, int]]) -> int:
        if not active_sources:
            return 0
        clauses = []
        parameters: list[object] = [ADAPTER_ID, ADAPTER_VERSION]
        for source_id, generation in active_sources:
            clauses.append("(source_id = ? AND source_generation = ?)")
            parameters.extend([source_id, generation])
        row = self.connection.execute(
            f"""
            SELECT count(*)
            FROM collector_diagnostics
            WHERE severity = 'strict'
              AND adapter_id = ?
              AND adapter_version = ?
              AND ({' OR '.join(clauses)})
            """,
            parameters,
        ).fetchone()
        return int(row[0]) if row else 0

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

    def _ensure_column(self, table: str, column: str, definition: str) -> None:
        self.connection.execute(f"ALTER TABLE {table} ADD COLUMN IF NOT EXISTS {column} {definition}")

    def _table_exists(self, table: str) -> bool:
        row = self.connection.execute(
            """
            SELECT count(*)
            FROM information_schema.tables
            WHERE table_name = ?
            """,
            [table],
        ).fetchone()
        return bool(row and row[0])

    def _columns(self, table: str) -> set[str]:
        rows = self.connection.execute(
            """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = ?
            """,
            [table],
        ).fetchall()
        return {str(row[0]) for row in rows}

    def _ensure_normalized_usage_schema(self) -> None:
        if not self._table_exists("normalized_usage_observations"):
            self._create_normalized_usage_table("normalized_usage_observations")
            return
        if "adapter_id" in self._columns("normalized_usage_observations"):
            return

        replacement = "normalized_usage_observations_v2"
        self.connection.execute(f"DROP TABLE IF EXISTS {replacement}")
        self._create_normalized_usage_table(replacement)
        self.connection.execute(
            f"""
            INSERT INTO {replacement} (
              source_id,
              source_generation,
              source_offset,
              adapter_id,
              adapter_version,
              adapter_digest,
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
            SELECT
              source_id,
              source_generation,
              source_offset,
              ?,
              ?,
              ?,
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
            FROM normalized_usage_observations
            """,
            [ADAPTER_ID, ADAPTER_VERSION, ADAPTER_DIGEST],
        )
        self.connection.execute("DROP TABLE normalized_usage_observations")
        self.connection.execute(f"ALTER TABLE {replacement} RENAME TO normalized_usage_observations")

    def _create_normalized_usage_table(self, table: str) -> None:
        self.connection.execute(
            f"""
            CREATE TABLE {table} (
              source_id TEXT NOT NULL,
              source_generation UBIGINT NOT NULL,
              source_offset UBIGINT NOT NULL,
              adapter_id TEXT NOT NULL,
              adapter_version TEXT NOT NULL,
              adapter_digest TEXT NOT NULL,
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
              PRIMARY KEY (
                source_id,
                source_generation,
                source_offset,
                adapter_id,
                adapter_version,
                adapter_digest
              )
            )
            """
        )

    def _checkpoint_anchor_matches(self, path: Path, checkpoint: SourceCheckpoint) -> bool:
        try:
            return _digest_file_range(path, checkpoint.anchor_start, checkpoint.anchor_end) == checkpoint.anchor_digest
        except OSError:
            return False


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


def _source_checkpoint(path: Path, source_id: str, source_generation: int, next_offset: int) -> SourceCheckpoint:
    anchor_end = next_offset
    anchor_start = max(0, anchor_end - ANCHOR_BYTE_WINDOW)
    return SourceCheckpoint(
        source_id=source_id,
        source_generation=source_generation,
        next_offset=next_offset,
        anchor_start=anchor_start,
        anchor_end=anchor_end,
        anchor_digest=_digest_file_range(path, anchor_start, anchor_end),
    )


def _digest_file_range(path: Path, start: int, end: int) -> str:
    if end < start:
        raise OSError(f"invalid anchor range: {start}:{end}")
    with path.open("rb") as handle:
        handle.seek(start)
        data = handle.read(end - start)
    if len(data) != end - start:
        raise OSError(f"incomplete anchor range: {start}:{end}")
    return "sha256:" + hashlib.sha256(data).hexdigest()
