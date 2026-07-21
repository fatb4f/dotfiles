#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import json
import os
import tempfile
import unittest
import sys
from datetime import datetime, timezone
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("codex_corpus_profile.py")
spec = importlib.util.spec_from_file_location("codex_corpus_profile", MODULE_PATH)
assert spec and spec.loader
ccp = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = ccp
spec.loader.exec_module(ccp)


def ts(value: str) -> datetime:
    parsed = ccp.parse_datetime_value(value, timezone.utc)
    assert parsed is not None
    return parsed


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


def usage(total: int, input_tokens: int, output_tokens: int, cached: int = 0, reasoning: int = 0) -> dict:
    return {
        "total_tokens": total,
        "input_tokens": input_tokens,
        "cached_input_tokens": cached,
        "output_tokens": output_tokens,
        "reasoning_output_tokens": reasoning,
    }


def write_jsonl(path: Path, rows: list[dict | str]) -> None:
    with path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write((row if isinstance(row, str) else json.dumps(row)) + "\n")


class CorpusProfilerTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.path = self.root / "session.jsonl"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def read(self):
        events, readable = ccp.read_events(self.path, timezone.utc)
        self.assertTrue(readable)
        return events

    def test_file_mtime_does_not_admit_old_events(self) -> None:
        write_jsonl(self.path, [{"timestamp": "2026-07-15T12:00:00Z", "type": "message"}])
        os.utime(self.path, None)  # Recent mtime must not affect evidence selection.
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.selected_lines, 0)

    def test_cumulative_snapshot_uses_pre_window_baseline(self) -> None:
        write_jsonl(self.path, [
            token_event("2026-07-17T23:00:00Z", total=usage(100, 80, 20)),
            token_event("2026-07-18T01:00:00Z", total=usage(150, 120, 30)),
        ])
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.tokens, ccp.TokenUsage(total=50, input=40, output=10))
        self.assertEqual(profile.token_missing_baseline, 0)
        self.assertEqual(profile.token_events_counted, 1)

    def test_incremental_usage_is_not_double_counted_with_total_snapshot(self) -> None:
        write_jsonl(self.path, [
            token_event("2026-07-17T23:00:00Z", total=usage(100, 80, 20)),
            token_event(
                "2026-07-18T01:00:00Z",
                total=usage(150, 120, 30),
                last=usage(50, 40, 10),
            ),
        ])
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.tokens.total, 50)
        self.assertEqual(profile.token_events_counted, 1)
        self.assertEqual(sum(profile.token_methods.values()), 1)

    def test_first_cumulative_snapshot_counts_from_zero_when_session_starts_in_window(self) -> None:
        write_jsonl(self.path, [
            {"timestamp": "2026-07-18T00:05:00Z", "type": "session_meta"},
            token_event("2026-07-18T00:10:00Z", total=usage(75, 60, 15)),
        ])
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.tokens.total, 75)
        self.assertEqual(profile.token_missing_baseline, 0)

    def test_cumulative_snapshot_without_baseline_is_rejected(self) -> None:
        write_jsonl(self.path, [
            {"timestamp": "2026-07-17T20:00:00Z", "type": "session_meta"},
            token_event("2026-07-18T01:00:00Z", total=usage(75, 60, 15)),
        ])
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.tokens.total, 0)
        self.assertEqual(profile.token_missing_baseline, 1)
        self.assertEqual(profile.token_coverage_status, "partial")

    def test_untimestamped_rows_are_excluded(self) -> None:
        write_jsonl(self.path, [
            {"type": "message", "payload": {"text": "no time"}},
            {"timestamp": "2026-07-18T01:00:00Z", "type": "message"},
        ])
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.untimestamped_lines, 1)
        self.assertEqual(profile.selected_lines, 1)

    def test_repeated_incremental_record_is_rejected_when_cumulative_does_not_advance(self) -> None:
        write_jsonl(self.path, [
            token_event("2026-07-17T23:00:00Z", total=usage(100, 80, 20)),
            token_event(
                "2026-07-18T01:00:00Z",
                total=usage(100, 80, 20),
                last=usage(50, 40, 10),
            ),
        ])
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.tokens.total, 0)
        self.assertEqual(profile.token_discrepancies, 1)
        self.assertEqual(profile.token_coverage_status, "partial")

    def test_repo_metadata_outside_window_can_identify_session(self) -> None:
        write_jsonl(self.path, [
            {
                "timestamp": "2026-07-17T20:00:00Z",
                "type": "session_meta",
                "payload": {"cwd": "/home/user/src/contract.cuemod"},
            },
            {"timestamp": "2026-07-18T01:00:00Z", "type": "message"},
        ])
        self.assertTrue(ccp.session_matches_repo(self.path, self.read(), "contract.cuemod"))
        self.assertFalse(ccp.session_matches_repo(self.path, self.read(), "unrelated.repo"))

    def test_counter_reset_is_reported_not_subtracted(self) -> None:
        write_jsonl(self.path, [
            token_event("2026-07-17T23:00:00Z", total=usage(100, 80, 20)),
            token_event("2026-07-18T01:00:00Z", total=usage(40, 30, 10)),
        ])
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.tokens.total, 0)
        self.assertEqual(profile.token_counter_resets, 1)

    def test_daily_attribution_uses_event_timestamp(self) -> None:
        write_jsonl(self.path, [
            token_event("2026-07-18T23:30:00Z", last=usage(10, 8, 2)),
            token_event("2026-07-19T00:30:00Z", last=usage(20, 15, 5)),
        ])
        profile, contributions = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-20T00:00:00Z")),
            timezone.utc,
        )
        daily = ccp.build_daily_profiles(
            [(profile.session_id or str(self.path), *item) for item in contributions],
            timezone.utc,
        )
        self.assertEqual([item.day for item in daily], ["2026-07-18", "2026-07-19"])
        self.assertEqual([item.tokens.total for item in daily], [10, 20])

    def test_cumulative_from_zero_requires_session_start_marker(self) -> None:
        write_jsonl(self.path, [
            token_event("2026-07-18T00:10:00Z", total=usage(75, 60, 15)),
        ])
        profile, _ = ccp.profile_session(
            self.path,
            self.read(),
            ccp.Window(ts("2026-07-18T00:00:00Z"), ts("2026-07-19T00:00:00Z")),
            timezone.utc,
        )
        self.assertEqual(profile.tokens.total, 0)
        self.assertEqual(profile.token_missing_baseline, 1)

    def test_main_writes_distinct_session_and_daily_csv_files(self) -> None:
        sessions = self.root / "sessions"
        sessions.mkdir()
        self.path = sessions / "session.jsonl"
        write_jsonl(self.path, [
            {
                "timestamp": "2026-07-18T00:00:00Z",
                "type": "session_meta",
                "payload": {"cwd": "/src/contract.cuemod"},
            },
            token_event("2026-07-18T00:10:00Z", last=usage(10, 8, 2)),
        ])
        out = self.root / "report"
        status = ccp.main([
            "--root", str(self.root),
            "--since", "2026-07-18T00:00:00Z",
            "--until", "2026-07-19T00:00:00Z",
            "--repo", "contract.cuemod",
            "--out", str(out),
        ])
        self.assertEqual(status, 0)
        session_csv = self.root / "report.csv"
        daily_csv = self.root / "report.daily.csv"
        self.assertTrue(session_csv.exists())
        self.assertTrue(daily_csv.exists())
        self.assertIn("session_id", session_csv.read_text(encoding="utf-8").splitlines()[0])
        self.assertIn("day,sessions", daily_csv.read_text(encoding="utf-8").splitlines()[0])


if __name__ == "__main__":
    unittest.main()
