#!/usr/bin/env sh
# managed Codex hook
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

log="$codex_state/stop.jsonl"

if command -v python3 >/dev/null 2>&1; then
  CODEX_HOOK_INPUT_FILE="$input_file" CODEX_HOOK_LOG="$log" CODEX_STATE="$codex_state" python3 - <<'PY'
import json
import os
import subprocess
import time
from pathlib import Path

raw = Path(os.environ["CODEX_HOOK_INPUT_FILE"]).read_text(encoding="utf-8", errors="replace")
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
status = run_git(["status", "--short"], repo_root)
recent = run_git(["log", "--date=short", "--pretty=format:%h %ad %s", "-n", "12"], repo_root)

context_frame = frames_dir / "context-frame.md"
repo_frame = frames_dir / "repo-frame.md"

def status_lines(value: str):
    if not value:
        return ["- clean: true"]
    return [f"- `{line}`" for line in value.splitlines() if line.strip()]

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
]
context_parts += status_lines(status)
context_parts += ["", "## Recent commits", ""]
context_parts += [f"- `{line}`" for line in recent.splitlines() if line.strip()] or ["- none"]
context_parts += [
    "",
    "## Operating rule",
    "",
    "- Refresh this frame at stop, not by committing automation.",
    "- Keep repo inspection scoped to the current repository.",
]

repo_parts = [
    "# Codex repo frame",
    "",
    f"- repo: `{repo_root}`",
    f"- branch: `{branch}`",
    f"- head: `{head}`",
    f"- upstream: `{upstream}`",
    "",
    "## Working tree",
    "",
]
repo_parts += status_lines(status)
repo_parts += ["", "## Recent commits", ""]
repo_parts += [f"- `{line}`" for line in recent.splitlines() if line.strip()] or ["- none"]

context_frame.write_text("\n".join(context_parts) + "\n", encoding="utf-8")
repo_frame.write_text("\n".join(repo_parts) + "\n", encoding="utf-8")

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
  cat "$input_file" >> "$log"
  printf '\n' >> "$log"
  printf '%s\n' '{"continue":true}'
fi
