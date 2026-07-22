#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path


PACKAGE_SRC = Path(__file__).resolve().parents[1] / "src"
if str(PACKAGE_SRC) not in sys.path:
    sys.path.insert(0, str(PACKAGE_SRC))

from codex_profile.cli import main as cli_main
from codex_profile.collector import ingest_rollouts
from codex_profile.adapters.usage import adapt_rollout_record
from codex_profile.sources.rollout import iter_complete_records, stable_source_id
from codex_profile.storage import ProfileStorage


def usage(total: int, input_tokens: int, output_tokens: int, cached: int = 0, reasoning: int = 0) -> dict:
    return {
        "total_tokens": total,
        "input_tokens": input_tokens,
        "cached_input_tokens": cached,
        "output_tokens": output_tokens,
        "reasoning_output_tokens": reasoning,
    }


def token_event(timestamp: str, *, total: dict | None = None, last: dict | None = None) -> dict:
    info: dict = {}
    if total is not None:
        info["total_token_usage"] = total
    if last is not None:
        info["last_token_usage"] = last
    return {
        "timestamp": timestamp,
        "type": "event_msg",
        "payload": {"type": "token_count", "info": info},
    }


def session_meta() -> dict:
    return {
        "timestamp": "2026-07-18T00:00:00Z",
        "type": "session_meta",
        "payload": {"cwd": "/home/_404/src/dotfiles"},
    }


def write_jsonl(path: Path, rows: list[dict]) -> None:
    path.write_text("".join(json.dumps(row, sort_keys=True) + "\n" for row in rows), encoding="utf-8")


class IngestionTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.sessions = self.root / "sessions"
        self.sessions.mkdir()
        self.rollout = self.sessions / "session.jsonl"
        self.database = self.root / "profile.duckdb"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def storage(self) -> ProfileStorage:
        return ProfileStorage(self.database)

    def test_ingesting_same_rollout_twice_is_idempotent(self) -> None:
        write_jsonl(self.rollout, [
            session_meta(),
            token_event("2026-07-18T00:01:00Z", last=usage(10, 8, 2)),
        ])
        storage = self.storage()
        try:
            first = ingest_rollouts(root=self.root, repo="dotfiles", storage=storage)
            second = ingest_rollouts(root=self.root, repo="dotfiles", storage=storage)
            self.assertEqual(first.counts.raw_inserted, 2)
            self.assertEqual(first.counts.normalized_inserted, 1)
            self.assertEqual(second.counts.raw_inserted, 0)
            self.assertEqual(second.counts.normalized_inserted, 0)
            self.assertEqual(storage.table_count("raw_rollout_observations"), 2)
            self.assertEqual(storage.table_count("normalized_usage_observations"), 1)
        finally:
            storage.close()

    def test_incremental_append_admits_exactly_one_new_record(self) -> None:
        write_jsonl(self.rollout, [session_meta()])
        storage = self.storage()
        try:
            ingest_rollouts(root=self.root, repo="dotfiles", storage=storage)
            with self.rollout.open("a", encoding="utf-8") as handle:
                handle.write(json.dumps(token_event("2026-07-18T00:01:00Z", last=usage(10, 8, 2))) + "\n")
            result = ingest_rollouts(root=self.root, repo="dotfiles", storage=storage)
            self.assertEqual(result.counts.raw_inserted, 1)
            self.assertEqual(result.counts.normalized_inserted, 1)
            self.assertEqual(storage.table_count("raw_rollout_observations"), 2)
        finally:
            storage.close()

    def test_incomplete_tail_is_ignored_until_completed(self) -> None:
        self.rollout.write_text(json.dumps(session_meta()) + "\n", encoding="utf-8")
        partial = json.dumps(token_event("2026-07-18T00:01:00Z", last=usage(10, 8, 2)))
        with self.rollout.open("a", encoding="utf-8") as handle:
            handle.write(partial)
        storage = self.storage()
        try:
            first = ingest_rollouts(root=self.root, repo="dotfiles", storage=storage)
            self.assertEqual(first.counts.raw_inserted, 1)
            self.assertEqual(storage.table_count("normalized_usage_observations"), 0)
            with self.rollout.open("a", encoding="utf-8") as handle:
                handle.write("\n")
            second = ingest_rollouts(root=self.root, repo="dotfiles", storage=storage)
            self.assertEqual(second.counts.raw_inserted, 1)
            self.assertEqual(second.counts.normalized_inserted, 1)
        finally:
            storage.close()

    def test_failed_transaction_does_not_advance_watermark(self) -> None:
        write_jsonl(self.rollout, [session_meta()])
        storage = self.storage()
        source_id = stable_source_id(self.rollout)
        try:
            with self.assertRaises(RuntimeError):
                ingest_rollouts(
                    root=self.root,
                    repo="dotfiles",
                    storage=storage,
                    fail_after_raw_at=(source_id, 0, 0),
                )
            self.assertEqual(storage.table_count("raw_rollout_observations"), 0)
            self.assertEqual(storage.get_watermark(source_id, 0), 0)
            result = ingest_rollouts(root=self.root, repo="dotfiles", storage=storage)
            self.assertEqual(result.counts.raw_inserted, 1)
            self.assertGreater(storage.get_watermark(source_id, 0), 0)
        finally:
            storage.close()

    def test_storage_rejects_non_collector_writer(self) -> None:
        with self.assertRaises(PermissionError):
            ProfileStorage(self.database, writer_id="reporter")
        write_jsonl(self.rollout, [session_meta()])
        storage = self.storage()
        try:
            ingest_rollouts(root=self.root, repo="dotfiles", storage=storage)
        finally:
            storage.close()
        reader = ProfileStorage(self.database, readonly=True)
        try:
            self.assertEqual(reader.summary()["raw_observations"], 1)
            source_id = stable_source_id(self.rollout)
            record = next(iter_complete_records(self.rollout))
            adapted = adapt_rollout_record(record)
            with self.assertRaises(PermissionError):
                reader.admit(adapted)
            self.assertEqual(reader.get_watermark(source_id, 0), len(json.dumps(session_meta(), sort_keys=True)) + 1)
        finally:
            reader.close()

    def test_strict_cli_returns_nonzero_for_invalid_accounting(self) -> None:
        write_jsonl(self.rollout, [
            session_meta(),
            token_event("2026-07-18T00:01:00Z", last=usage(10, 5, 5, cached=6)),
        ])
        status = cli_main([
            "ingest",
            "--root",
            str(self.root),
            "--repo",
            "dotfiles",
            "--database",
            str(self.database),
            "--strict",
        ])
        self.assertEqual(status, 3)
        storage = self.storage()
        try:
            self.assertEqual(storage.table_count("collector_diagnostics"), 1)
            self.assertEqual(storage.table_count("normalized_usage_observations"), 0)
        finally:
            storage.close()

    def test_strict_cli_records_unknown_shape_and_missing_attribution(self) -> None:
        self.rollout.write_text('[1, 2, 3]\n{"type": "message"}\n', encoding="utf-8")
        status = cli_main([
            "ingest",
            "--root",
            str(self.root),
            "--database",
            str(self.database),
            "--strict",
        ])
        self.assertEqual(status, 3)
        storage = self.storage()
        try:
            codes = {
                row[0]
                for row in storage.connection.execute(
                    "SELECT code FROM collector_diagnostics ORDER BY code"
                ).fetchall()
            }
            self.assertIn("rollout.unknown-shape", codes)
            self.assertIn("rollout.missing-event-timestamp", codes)
        finally:
            storage.close()

    def test_analyze_and_export_cli_emit_summary(self) -> None:
        write_jsonl(self.rollout, [
            session_meta(),
            token_event("2026-07-18T00:01:00Z", last=usage(10, 8, 2, cached=3)),
        ])
        self.assertEqual(cli_main([
            "ingest",
            "--root",
            str(self.root),
            "--repo",
            "dotfiles",
            "--database",
            str(self.database),
        ]), 0)
        self.assertEqual(cli_main(["analyze", "--database", str(self.database)]), 0)
        out = self.root / "export"
        self.assertEqual(cli_main(["export", "--database", str(self.database), "--out", str(out)]), 0)
        summary = json.loads((out / "summary.json").read_text(encoding="utf-8"))
        self.assertEqual(summary["tokens"]["total"], 10)
        self.assertEqual(summary["tokens"]["fresh_input"], 5)
        self.assertTrue((out / "summary.md").exists())
        self.assertTrue((out / "summary.csv").exists())


if __name__ == "__main__":
    unittest.main()
