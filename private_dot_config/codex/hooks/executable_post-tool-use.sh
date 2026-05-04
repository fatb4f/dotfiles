#!/usr/bin/env sh
# generated Codex PostToolUse hook
# shellcheck shell=sh
set -eu

input=$(cat)
: "${XDG_STATE_HOME:=$HOME/.local/state}"
state_dir="$XDG_STATE_HOME/_404/codex"
log="$state_dir/post-tool-use.jsonl"
mkdir -p "$state_dir"

if command -v python3 >/dev/null 2>&1; then
  CODEX_HOOK_INPUT=$input CODEX_HOOK_LOG=$log python3 - <<'PY'
import json, os, time
raw = os.environ.get("CODEX_HOOK_INPUT", "")
log = os.environ["CODEX_HOOK_LOG"]
try:
    event = json.loads(raw or "{}")
except Exception as exc:
    event = {"_parse_error": str(exc), "raw": raw}

tool_input = event.get("tool_input") if isinstance(event.get("tool_input"), dict) else {}
tool_response = event.get("tool_response")
record = {
    "ts": int(time.time()),
    "event": "PostToolUse",
    "session_id": event.get("session_id"),
    "turn_id": event.get("turn_id"),
    "tool_name": event.get("tool_name"),
    "command": tool_input.get("command"),
    "response_type": type(tool_response).__name__,
}
with open(log, "a", encoding="utf-8") as fh:
    fh.write(json.dumps(record, sort_keys=True) + "\n")
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": "Bash result was recorded to the local Codex evidence stream."
    }
}))
PY
else
  printf '%s\n' "$input" >> "$log"
  printf '%s\n' '{}'
fi
