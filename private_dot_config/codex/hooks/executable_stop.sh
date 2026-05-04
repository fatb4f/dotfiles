#!/usr/bin/env sh
# generated Codex Stop hook
# shellcheck shell=sh
set -eu

input=$(cat)
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
state_dir="$XDG_STATE_HOME/_404/codex"
log="$state_dir/stop.jsonl"
mkdir -p "$state_dir"

if command -v python3 >/dev/null 2>&1; then
  CODEX_HOOK_INPUT=$input CODEX_HOOK_LOG=$log XDG_STATE_HOME=$XDG_STATE_HOME XDG_CONFIG_HOME=$XDG_CONFIG_HOME python3 - <<'PY'
import json
import os
import subprocess
import time
from pathlib import Path

raw = os.environ.get("CODEX_HOOK_INPUT", "")
log = os.environ["CODEX_HOOK_LOG"]
try:
    event = json.loads(raw or "{}")
except Exception as exc:
    event = {"_parse_error": str(exc), "raw": raw}

cwd = event.get("cwd") or os.getcwd()
session_id = event.get("session_id") or ""
source = event.get("source") or ""
model = event.get("model") or ""

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
    print(json.dumps({
        "continue": True,
        "hookSpecificOutput": {
            "hookEventName": "Stop",
            "additionalContext": "No git root detected; context frame was not refreshed.",
        },
    }))
    raise SystemExit(0)

repo = Path(repo_root)
frames_dir = repo / ".codex" / "frames"
frames_dir.mkdir(parents=True, exist_ok=True)

branch = run_git(["branch", "--show-current"], repo_root) or "detached-or-unknown"
head = run_git(["rev-parse", "--short", "HEAD"], repo_root) or "unknown"
upstream = run_git(["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"], repo_root) or "none"
status = run_git(["status", "--short"], repo_root) or "clean"
recent = run_git(["log", "--date=short", "--pretty=format:%h %ad %s", "-n", "12"], repo_root)

context_frame = frames_dir / "context-frame.md"
repo_frame = frames_dir / "repo-frame.md"

context_parts = [
    "# Codex context frame",
    "",
    "## Stop snapshot",
    "",
    f"- session: `{session_id or 'unknown'}`",
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
    "",
    "## Working tree",
    "",
    f"- {status}",
    "",
    "## Recent commits",
    "",
]
context_parts += [f"- `{line}`" for line in recent.splitlines() if line.strip()] or ["- none"]
context_parts += [
    "",
    "## Operating rule",
    "",
    "- Refresh this frame at stop, not by committing automation.",
    "- Keep repo inspection scoped to the current repository.",
]

context_frame.write_text("\n".join(context_parts) + "\n", encoding="utf-8")
repo_frame.write_text(
    "\n".join([
        "# Codex repo frame",
        "",
        f"- repo: `{repo_root}`",
        f"- branch: `{branch}`",
        f"- head: `{head}`",
        f"- upstream: `{upstream}`",
        "",
        "## Working tree",
        "",
        f"- {status}",
        "",
        "## Recent commits",
        "",
        *([f"- `{line}`" for line in recent.splitlines() if line.strip()] or ["- none"]),
    ]) + "\n",
    encoding="utf-8",
)

with open(log, "a", encoding="utf-8") as fh:
    fh.write(json.dumps({
        "ts": int(time.time()),
        "event": "Stop",
        "session_id": session_id,
        "source": source,
        "model": model,
        "cwd": cwd,
        "repo_root": repo_root,
        "context_frame": str(context_frame),
        "repo_frame": str(repo_frame),
    }, sort_keys=True) + "\n")

print(json.dumps({
    "continue": True,
    "hookSpecificOutput": {
        "hookEventName": "Stop",
        "additionalContext": "Refreshed context-frame.md and repo-frame.md. No commit automation was performed.",
    },
}))
PY
else
  printf '%s\n' "$input" >> "$log"
  printf '%s\n' '{"continue":true}'
fi
