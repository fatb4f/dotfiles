#!/usr/bin/env sh
# generated Codex PreToolUse hook
# shellcheck shell=sh
set -eu

input=$(cat)
: "${XDG_STATE_HOME:=$HOME/.local/state}"
state_dir="$XDG_STATE_HOME/_404/codex"
log="$state_dir/pre-tool-use.jsonl"
mkdir -p "$state_dir"

if command -v python3 >/dev/null 2>&1; then
  CODEX_HOOK_INPUT=$input CODEX_HOOK_LOG=$log python3 - <<'PY'
import json, os, re, time
raw = os.environ.get("CODEX_HOOK_INPUT", "")
log = os.environ["CODEX_HOOK_LOG"]
try:
    event = json.loads(raw or "{}")
except Exception as exc:
    event = {"_parse_error": str(exc), "raw": raw}

tool_input = event.get("tool_input") if isinstance(event.get("tool_input"), dict) else {}
command = str(tool_input.get("command") or "")

rules = [
    (r"(^|[;&|]\s*)sudo\b", "sudo is outside the slim Codex profile"),
    (r"\brm\s+-[^\n;]*[rf][^\n;]*\s+/(\s|$)", "recursive deletion of / is blocked"),
    (r"\b(chmod|chown)\s+[^\n;]*(/etc|/usr|/bin|/sbin)(\s|/|$)", "system path mutation is blocked"),
    (r"\b(curl|wget)\b[^\n;|]*\|\s*(sh|bash)\b", "curl/wget pipe-to-shell is blocked"),
]

deny_reason = None
for pattern, reason in rules:
    if re.search(pattern, command):
        deny_reason = reason
        break

record = {
    "ts": int(time.time()),
    "event": "PreToolUse",
    "session_id": event.get("session_id"),
    "turn_id": event.get("turn_id"),
    "tool_name": event.get("tool_name"),
    "command": command,
    "decision": "deny" if deny_reason else "allow",
    "reason": deny_reason,
}
with open(log, "a", encoding="utf-8") as fh:
    fh.write(json.dumps(record, sort_keys=True) + "\n")

if deny_reason:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": deny_reason,
        }
    }))
else:
    print(json.dumps({"systemMessage": "Codex slim profile hook: Bash command checked."}))
PY
else
  printf '%s\n' "$input" >> "$log"
  printf '%s\n' '{}'
fi
