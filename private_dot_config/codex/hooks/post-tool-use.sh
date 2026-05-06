#!/usr/bin/env sh
# managed Codex hook
# Quota profile: silent success path; local evidence only.
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

log="$codex_state/post-tool-use.jsonl"

if command -v python3 >/dev/null 2>&1; then
  CODEX_HOOK_INPUT_FILE="$input_file" CODEX_HOOK_LOG="$log" python3 - <<'PY_POST'
import json
import os
import time
from pathlib import Path

raw = Path(os.environ["CODEX_HOOK_INPUT_FILE"]).read_text(encoding="utf-8", errors="replace")
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

# Silent success path. The evidence stream is local; do not inject context per Bash result.
print(json.dumps({"continue": True}))
PY_POST
else
  cat "$input_file" >> "$log"
  printf '\n' >> "$log"
  printf '%s\n' '{"continue":true}'
fi
