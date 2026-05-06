#!/usr/bin/env sh
# managed Codex hook
# Quota profile: write frame files, inject only a compact pointer.
# shellcheck shell=sh
set -eu

: "${HOME:?HOME is required}"

xdg_state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
codex_state="${CODEX_STATE:-$xdg_state_home/codex}"

mkdir -p "$codex_state"
chmod 700 "$codex_state" 2>/dev/null || true

input_file=$(mktemp "${TMPDIR:-/tmp}/codex-hook.XXXXXX")
trap 'rm -f "$input_file"' EXIT HUP INT TERM
cat > "$input_file"

if ! command -v python3 >/dev/null 2>&1; then
  printf '%s\n' '{"continue":true}'
  exit 0
fi

CODEX_HOOK_INPUT_FILE="$input_file" CODEX_STATE="$codex_state" python3 - <<'PY_SESSION'
import json
import os
import re
import subprocess
import time
from pathlib import Path

raw = Path(os.environ["CODEX_HOOK_INPUT_FILE"]).read_text(encoding="utf-8", errors="replace")
try:
    event = json.loads(raw or "{}")
except Exception as exc:
    event = {"_parse_error": str(exc), "raw": raw}

sid = event.get("session_id") or ""
source = event.get("source") or ""
model = event.get("model") or ""
cwd = event.get("cwd") or os.getcwd()

state_dir = Path(os.environ["CODEX_STATE"]).expanduser()
state_dir.mkdir(parents=True, exist_ok=True)


def run_git(args, repo_cwd):
    try:
        out = subprocess.check_output(
            ["git", "-C", repo_cwd, *args],
            stderr=subprocess.DEVNULL,
            text=True,
        )
        return out.strip()
    except Exception:
        return ""

repo_root = run_git(["rev-parse", "--show-toplevel"], cwd)
if not repo_root:
    msg = (
        f"No git root detected for cwd `{cwd}`. "
        "Start Codex from a specific repository/subtree. "
        "Do not crawl from `$HOME` to infer context."
    )
    print(json.dumps({
        "continue": True,
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": msg,
        },
    }))
    raise SystemExit(0)

repo = Path(repo_root)
frames_dir = repo / ".codex" / "frames"
frames_dir.mkdir(parents=True, exist_ok=True)

session_frame = frames_dir / "session-frame.md"
session_log = state_dir / "session-init.jsonl"


def mask_remote(url: str) -> str:
    return re.sub(r"(https?://)([^/@:]+)(:[^/@]+)?@", r"\1***@", url)


def lines(text: str, limit: int):
    return [line for line in text.splitlines() if line.strip()][:limit]

branch = run_git(["branch", "--show-current"], repo_root) or "detached-or-unknown"
head = run_git(["rev-parse", "--short", "HEAD"], repo_root) or "unknown"
upstream = run_git(["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"], repo_root) or "none"
status = run_git(["status", "--short"], repo_root)

remotes_raw = run_git(["remote", "-v"], repo_root)
remotes = []
seen_remotes = set()
for line in remotes_raw.splitlines():
    parts = line.split()
    if len(parts) >= 3 and parts[2] == "(fetch)":
        item = f"- `{parts[0]}` {mask_remote(parts[1])}"
        if item not in seen_remotes:
            remotes.append(item)
            seen_remotes.add(item)

commits_raw = run_git([
    "log",
    "--date=short",
    "--pretty=format:%h %ad %s",
    "-n",
    "12",
], repo_root)

dirty_count = len([line for line in status.splitlines() if line.strip()])

parts = [
    "# Codex session frame",
    "",
    "## Startup",
    "",
    f"- session: `{sid or 'unknown'}`",
    f"- source: `{source or 'unknown'}`",
    f"- model: `{model or 'unknown'}`",
    f"- cwd: `{cwd}`",
    f"- repo: `{repo_root}`",
    "",
    "## Git state",
    "",
    f"- branch: `{branch}`",
    f"- head: `{head}`",
    f"- upstream: `{upstream}`",
    f"- dirty_paths: `{dirty_count}`",
    "",
    "## Remotes",
    "",
]

parts += remotes[:8] if remotes else ["- none"]
parts += ["", "## Recent commits", ""]
parts += [f"- `{line}`" for line in lines(commits_raw, 12)] or ["- none"]
parts += ["", "## Working tree", ""]
parts += [f"- `{line}`" for line in lines(status, 60)] if status else ["- clean: true"]
parts += [
    "",
    "## Tool history",
    "",
    "- local evidence may exist under `$CODEX_STATE`",
    "- do not load previous tool history unless the user asks for forensic review",
    "",
    "## Operating rule",
    "",
    "- Use frame files before broad repo inspection.",
    "- Prefer git log, repo-frame, and context-frame over transcript resume.",
    "- Do not crawl from `$HOME`.",
    "- If the task is broad, produce a bounded slice before reading the repo.",
]

session_frame.write_text("\n".join(parts) + "\n", encoding="utf-8")

with session_log.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps({
        "ts": int(time.time()),
        "event": "SessionStart",
        "session_id": sid,
        "source": source,
        "model": model,
        "cwd": cwd,
        "repo_root": repo_root,
        "frame": str(session_frame),
        "dirty_paths": dirty_count,
    }, sort_keys=True) + "\n")

ctx = (
    "Codex startup frame refreshed at `.codex/frames/session-frame.md`. "
    "Read frame files before broad repo discovery; do not resume old transcript unless explicitly requested."
)

print(json.dumps({
    "continue": True,
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": ctx,
    },
}))
PY_SESSION
