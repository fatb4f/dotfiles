#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import math
import os
import re
import sys
from collections import Counter, defaultdict, deque
from dataclasses import dataclass, asdict
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Any, Iterable


ISO_RE = re.compile(r"^\d{4}-\d{2}-\d{2}[T ][0-2]\d:[0-5]\d:[0-5]\d")

ROLE_VALUES = {"user", "assistant", "system", "developer", "tool"}


@dataclass
class Event:
    ts: datetime
    file: str
    line: int
    kind: str
    role: str | None
    model: str | None
    chars: int
    est_tokens: int
    input_tokens: int
    output_tokens: int
    total_tokens: int


def parse_time(v: Any) -> datetime | None:
    if isinstance(v, (int, float)):
        # epoch seconds or milliseconds
        if v > 10_000_000_000:
            v = v / 1000
        try:
            return datetime.fromtimestamp(v, tz=timezone.utc)
        except Exception:
            return None

    if not isinstance(v, str):
        return None

    s = v.strip()
    if not s:
        return None

    if s.endswith("Z"):
        s = s[:-1] + "+00:00"

    if not ISO_RE.match(s):
        return None

    try:
        dt = datetime.fromisoformat(s)
    except Exception:
        return None

    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)

    return dt.astimezone(timezone.utc)


def walk(obj: Any, path: tuple[str, ...] = ()) -> Iterable[tuple[tuple[str, ...], Any]]:
    yield path, obj
    if isinstance(obj, dict):
        for k, v in obj.items():
            yield from walk(v, path + (str(k),))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            yield from walk(v, path + (str(i),))


def find_timestamp(obj: Any) -> datetime | None:
    priority = [
        "timestamp",
        "ts",
        "time",
        "created_at",
        "createdAt",
        "updated_at",
        "updatedAt",
        "started_at",
        "startedAt",
    ]

    if isinstance(obj, dict):
        for k in priority:
            if k in obj:
                dt = parse_time(obj[k])
                if dt:
                    return dt

    for path, v in walk(obj):
        if not path:
            continue
        leaf = path[-1].lower()
        if any(
            x in leaf for x in ("time", "timestamp", "created", "updated", "started")
        ):
            dt = parse_time(v)
            if dt:
                return dt

    return None


def find_role(obj: Any) -> str | None:
    for path, v in walk(obj):
        if path and path[-1].lower() == "role" and isinstance(v, str):
            r = v.lower()
            if r in ROLE_VALUES:
                return r
    return None


def find_model(obj: Any) -> str | None:
    candidates = []
    for path, v in walk(obj):
        if not isinstance(v, str):
            continue
        if not path:
            continue
        leaf = path[-1].lower()
        if leaf == "model" or leaf.endswith("_model") or leaf == "model_name":
            candidates.append(v)

    if not candidates:
        return None

    # Prefer model-ish strings.
    for c in candidates:
        if any(x in c.lower() for x in ("gpt", "codex", "oai")):
            return c

    return candidates[0]


def find_kind(obj: Any, role: str | None, usage_total: int) -> str:
    type_values = []

    for path, v in walk(obj):
        if (
            isinstance(v, str)
            and path
            and path[-1].lower() in {"type", "event", "kind"}
        ):
            type_values.append(v.lower())

    joined = " ".join(type_values)

    if role == "user":
        return "user_turn"

    if "user" in joined and "message" in joined:
        return "user_turn"

    if usage_total > 0:
        return "api_usage"

    if "tool" in joined:
        return "tool_event"

    if "assistant" in joined:
        return "assistant_event"

    return "other"


def usage_from_obj(obj: Any) -> tuple[int, int, int]:
    best = (0, 0, 0)

    for _, v in walk(obj):
        if not isinstance(v, dict):
            continue

        lower = {str(k).lower(): val for k, val in v.items()}

        input_tokens = lower.get("input_tokens", lower.get("prompt_tokens", 0))
        output_tokens = lower.get("output_tokens", lower.get("completion_tokens", 0))
        total_tokens = lower.get("total_tokens", 0)

        try:
            i = int(input_tokens or 0)
            o = int(output_tokens or 0)
            t = int(total_tokens or 0)
        except Exception:
            continue

        if t == 0 and (i or o):
            t = i + o

        if t > best[2]:
            best = (i, o, t)

    return best


def text_chars(obj: Any, role: str | None) -> int:
    chunks: list[str] = []

    preferred_keys = {
        "content",
        "text",
        "prompt",
        "input",
        "message",
    }

    for path, v in walk(obj):
        if not isinstance(v, str):
            continue
        if not path:
            continue

        leaf = path[-1].lower()

        if leaf in preferred_keys:
            # Avoid counting obvious metadata strings as content.
            if len(v) >= 2:
                chunks.append(v)

    if not chunks:
        return 0

    # If this is not a user event, text is less useful for quota approximation.
    if role and role != "user":
        return 0

    return sum(len(c) for c in chunks)


def est_tokens(chars: int) -> int:
    # Crude but useful fallback when exact token accounting is absent.
    return math.ceil(chars / 4) if chars > 0 else 0


def discover_files(home: Path) -> list[Path]:
    files: list[Path] = []

    history = home / "history.jsonl"
    if history.exists():
        files.append(history)

    sessions = home / "sessions"
    if sessions.exists():
        files.extend(sorted(sessions.rglob("*.jsonl")))

    logs = home / "logs"
    if logs.exists():
        files.extend(sorted(logs.rglob("*.jsonl")))

    # De-duplicate while preserving order.
    seen = set()
    out = []
    for f in files:
        try:
            rp = f.resolve()
        except Exception:
            rp = f
        if rp not in seen and f.is_file():
            seen.add(rp)
            out.append(f)

    return out


def read_events(files: list[Path]) -> tuple[list[Event], Counter]:
    events: list[Event] = []
    stats = Counter()

    for f in files:
        try:
            rel = str(f)
            with f.open("r", encoding="utf-8", errors="replace") as fh:
                for n, line in enumerate(fh, start=1):
                    stats["lines"] += 1
                    line = line.strip()
                    if not line:
                        continue

                    try:
                        obj = json.loads(line)
                    except Exception:
                        stats["bad_json"] += 1
                        continue

                    ts = find_timestamp(obj)
                    if not ts:
                        stats["undated"] += 1
                        continue

                    role = find_role(obj)
                    model = find_model(obj)
                    i, o, t = usage_from_obj(obj)
                    chars = text_chars(obj, role)
                    kind = find_kind(obj, role, t)

                    events.append(
                        Event(
                            ts=ts,
                            file=rel,
                            line=n,
                            kind=kind,
                            role=role,
                            model=model,
                            chars=chars,
                            est_tokens=est_tokens(chars),
                            input_tokens=i,
                            output_tokens=o,
                            total_tokens=t,
                        )
                    )
        except Exception as e:
            stats["file_errors"] += 1
            print(f"warning: could not read {f}: {e}", file=sys.stderr)

    events.sort(key=lambda e: e.ts)
    return events, stats


def rolling_worst(
    events: list[Event], hours: float
) -> tuple[datetime | None, int, int, int]:
    window = timedelta(hours=hours)
    q: deque[Event] = deque()

    best_end = None
    best_turns = 0
    best_usage_events = 0
    best_tokens = 0

    turns = 0
    usage_events = 0
    tokens = 0

    for e in events:
        q.append(e)

        if e.kind == "user_turn":
            turns += 1
        if e.total_tokens > 0:
            usage_events += 1
        tokens += e.total_tokens or e.est_tokens

        while q and q[0].ts < e.ts - window:
            old = q.popleft()
            if old.kind == "user_turn":
                turns -= 1
            if old.total_tokens > 0:
                usage_events -= 1
            tokens -= old.total_tokens or old.est_tokens

        score = turns
        if score > best_turns:
            best_end = e.ts
            best_turns = turns
            best_usage_events = usage_events
            best_tokens = tokens

    return best_end, best_turns, best_usage_events, best_tokens


def summarize(
    events: list[Event], home: Path, hours: float, days: int
) -> dict[str, Any]:
    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(hours=hours)
    since_days = now - timedelta(days=days)

    recent = [e for e in events if e.ts >= cutoff]
    scoped = [e for e in events if e.ts >= since_days]

    by_kind = Counter(e.kind for e in recent)
    by_model = Counter(e.model or "unknown" for e in recent if e.model)
    by_day = defaultdict(lambda: Counter())

    for e in scoped:
        d = e.ts.astimezone().date().isoformat()
        by_day[d]["events"] += 1
        if e.kind == "user_turn":
            by_day[d]["user_turns"] += 1
        if e.total_tokens:
            by_day[d]["exact_tokens"] += e.total_tokens
        by_day[d]["estimated_tokens"] += e.total_tokens or e.est_tokens

    by_file = defaultdict(lambda: Counter())
    for e in recent:
        by_file[e.file]["events"] += 1
        if e.kind == "user_turn":
            by_file[e.file]["user_turns"] += 1
        if e.total_tokens:
            by_file[e.file]["exact_tokens"] += e.total_tokens
        by_file[e.file]["estimated_tokens"] += e.total_tokens or e.est_tokens
        by_file[e.file]["chars"] += e.chars

    worst_end, worst_turns, worst_usage_events, worst_tokens = rolling_worst(
        scoped, hours
    )

    max_context = max((e.input_tokens for e in scoped), default=0)
    max_total = max((e.total_tokens for e in scoped), default=0)

    largest_user = max(
        (e for e in scoped if e.kind == "user_turn"),
        key=lambda e: e.est_tokens,
        default=None,
    )

    return {
        "codex_home": str(home),
        "now_utc": now.isoformat(),
        "window_hours": hours,
        "history_days": days,
        "event_count_total": len(events),
        "event_count_last_window": len(recent),
        "last_window": {
            "since_utc": cutoff.isoformat(),
            "events": len(recent),
            "user_turns": by_kind["user_turn"],
            "api_usage_events": by_kind["api_usage"],
            "exact_input_tokens": sum(e.input_tokens for e in recent),
            "exact_output_tokens": sum(e.output_tokens for e in recent),
            "exact_total_tokens": sum(e.total_tokens for e in recent),
            "estimated_total_tokens": sum(
                e.total_tokens or e.est_tokens for e in recent
            ),
            "models": dict(by_model),
        },
        "worst_rolling_window": {
            "ending_utc": worst_end.isoformat() if worst_end else None,
            "user_turns": worst_turns,
            "api_usage_events": worst_usage_events,
            "estimated_or_exact_tokens": worst_tokens,
        },
        "context_pressure": {
            "max_exact_input_tokens_single_event": max_context,
            "max_exact_total_tokens_single_event": max_total,
            "largest_user_turn": asdict(largest_user) if largest_user else None,
        },
        "top_recent_files": [
            {"file": f, **dict(c)}
            for f, c in sorted(
                by_file.items(),
                key=lambda kv: (
                    kv[1]["estimated_tokens"],
                    kv[1]["user_turns"],
                    kv[1]["events"],
                ),
                reverse=True,
            )[:10]
        ],
        "daily": {d: dict(c) for d, c in sorted(by_day.items())},
    }


def print_human(report: dict[str, Any], parser_stats: Counter, file_count: int) -> None:
    lw = report["last_window"]
    wr = report["worst_rolling_window"]
    cp = report["context_pressure"]

    print("Codex usage audit")
    print("=================")
    print(f"CODEX_HOME: {report['codex_home']}")
    print(f"files scanned: {file_count}")
    print(f"jsonl lines: {parser_stats['lines']}")
    print(f"bad json lines: {parser_stats['bad_json']}")
    print(f"undated json lines skipped: {parser_stats['undated']}")
    print()

    print(f"Last {report['window_hours']}h window")
    print("-------------------")
    print(f"since UTC: {lw['since_utc']}")
    print(f"events: {lw['events']}")
    print(f"user turns: {lw['user_turns']}")
    print(f"api usage events with token fields: {lw['api_usage_events']}")
    print(f"exact input tokens: {lw['exact_input_tokens']}")
    print(f"exact output tokens: {lw['exact_output_tokens']}")
    print(f"exact total tokens: {lw['exact_total_tokens']}")
    print(f"estimated total tokens: {lw['estimated_total_tokens']}")
    if lw["models"]:
        print("models:")
        for model, count in sorted(
            lw["models"].items(), key=lambda kv: kv[1], reverse=True
        ):
            print(f"  {model}: {count}")
    print()

    print(
        f"Worst rolling {report['window_hours']}h window in last {report['history_days']}d"
    )
    print("---------------------------------------------")
    print(f"ending UTC: {wr['ending_utc']}")
    print(f"user turns: {wr['user_turns']}")
    print(f"api usage events: {wr['api_usage_events']}")
    print(f"estimated/exact tokens: {wr['estimated_or_exact_tokens']}")
    print()

    print("Context pressure")
    print("----------------")
    print(
        f"max exact input tokens in one event: {cp['max_exact_input_tokens_single_event']}"
    )
    print(
        f"max exact total tokens in one event: {cp['max_exact_total_tokens_single_event']}"
    )
    if cp["largest_user_turn"]:
        e = cp["largest_user_turn"]
        print("largest observed user turn:")
        print(f"  UTC: {e['ts']}")
        print(f"  estimated tokens: {e['est_tokens']}")
        print(f"  chars: {e['chars']}")
        print(f"  file: {e['file']}:{e['line']}")
    print()

    print("Top recent files")
    print("----------------")
    for item in report["top_recent_files"]:
        print(
            f"{item.get('estimated_tokens', 0):>8} est/exact tok | "
            f"{item.get('user_turns', 0):>3} user turns | "
            f"{item.get('events', 0):>4} events | "
            f"{item['file']}"
        )
    print()

    print("Daily summary")
    print("-------------")
    for day, c in report["daily"].items():
        print(
            f"{day} | "
            f"user_turns={c.get('user_turns', 0)} "
            f"events={c.get('events', 0)} "
            f"exact_tokens={c.get('exact_tokens', 0)} "
            f"estimated_tokens={c.get('estimated_tokens', 0)}"
        )

    print()
    print("Notes")
    print("-----")
    print(
        "- Exact quota remaining is server-side; use Codex settings > Usage for authority."
    )
    print("- Token fields depend on what your Codex build writes into JSONL.")
    print("- Estimated tokens use chars/4 and are only a pressure signal.")
    print("- User turns are usually the best local proxy for five-hour-window burn.")


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Estimate local Codex activity and context pressure from CODEX_HOME JSONL."
    )
    ap.add_argument(
        "--codex-home",
        default=os.environ.get("CODEX_HOME", str(Path.home() / ".codex")),
        help="Codex state directory. Defaults to $CODEX_HOME or ~/.codex.",
    )
    ap.add_argument("--hours", type=float, default=5.0, help="Window size. Default: 5.")
    ap.add_argument(
        "--days", type=int, default=7, help="History range for rolling/daily report."
    )
    ap.add_argument("--json", action="store_true", help="Print machine-readable JSON.")
    args = ap.parse_args()

    home = Path(args.codex_home).expanduser()
    if not home.exists():
        print(f"error: CODEX_HOME not found: {home}", file=sys.stderr)
        return 2

    files = discover_files(home)
    events, stats = read_events(files)
    report = summarize(events, home, args.hours, args.days)

    if args.json:
        print(json.dumps(report, indent=2, default=str))
    else:
        print_human(report, stats, len(files))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
