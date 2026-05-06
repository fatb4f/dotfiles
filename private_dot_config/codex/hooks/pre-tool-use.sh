#!/usr/bin/env sh
# managed Codex hook
# Quota profile: silent allow path; speak only on deny.
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

log="$codex_state/pre-tool-use.jsonl"

if command -v python3 >/dev/null 2>&1; then
  CODEX_HOOK_INPUT_FILE="$input_file" CODEX_HOOK_LOG="$log" python3 - <<'PY_PRE'
import json
import os
import re
import shlex
import time
from pathlib import Path

raw = Path(os.environ["CODEX_HOOK_INPUT_FILE"]).read_text(encoding="utf-8", errors="replace")
log = os.environ["CODEX_HOOK_LOG"]
try:
    event = json.loads(raw or "{}")
except Exception as exc:
    event = {"_parse_error": str(exc), "raw": raw}

tool_input = event.get("tool_input") if isinstance(event.get("tool_input"), dict) else {}
command = str(tool_input.get("command") or "")


def tokenized(cmd: str):
    try:
        return shlex.split(cmd, posix=True)
    except Exception:
        return cmd.split()


def suspicious_rm_root(cmd: str) -> bool:
    tokens = tokenized(cmd)
    separators = {";", "&&", "||", "|"}
    for idx, tok in enumerate(tokens):
        if tok == "rm" or tok.endswith("/rm"):
            flags = []
            targets = []
            for item in tokens[idx + 1:]:
                if item in separators:
                    break
                if item == "--":
                    continue
                if item.startswith("-") and item != "-":
                    flags.append(item)
                else:
                    targets.append(item)
            flag_text = "".join(flags)
            recursive = "r" in flag_text or "R" in flag_text
            force = "f" in flag_text
            root_target = any(t in {"/", "/*", "/."} or t.startswith("//") for t in targets)
            if recursive and force and root_target:
                return True
    return False


def unbounded_find_home_or_root(cmd: str) -> bool:
    return re.search(r"(^|[;&|]\s*)find\s+(\$HOME|~|/)(\s|$)", cmd) is not None


def unbounded_tree_home_or_root(cmd: str) -> bool:
    return re.search(r"(^|[;&|]\s*)tree\s+(\$HOME|~|/)(\s|$)", cmd) is not None


def unbounded_rg_home_or_root(cmd: str) -> bool:
    return re.search(r"(^|[;&|]\s*)rg\s+([^\n;|]+\s+)?(\$HOME|~|/)(\s|$)", cmd) is not None

rules = [
    (lambda c: re.search(r"(^|[;&|]\s*)sudo\b", c) is not None, "sudo is outside the slim Codex profile"),
    (suspicious_rm_root, "recursive forced deletion of / is blocked"),
    (
        lambda c: re.search(r"\b(chmod|chown)\s+[^\n;|]*(/etc|/usr|/bin|/sbin)(\s|/|$)", c) is not None,
        "system path ownership or mode mutation is blocked",
    ),
    (
        lambda c: re.search(r"\b(curl|wget)\b[^\n;|]*\|\s*(sh|bash)\b", c) is not None,
        "curl/wget pipe-to-shell is blocked",
    ),
    (unbounded_find_home_or_root, "unbounded find over HOME or / is blocked; use repo-scoped search with -maxdepth"),
    (unbounded_tree_home_or_root, "unbounded tree over HOME or / is blocked; inspect a bounded repo path instead"),
    (unbounded_rg_home_or_root, "unbounded ripgrep over HOME or / is blocked; use repo-rg or an explicit repo path"),
]

deny_reason = None
for predicate, reason in rules:
    try:
        if predicate(command):
            deny_reason = reason
            break
    except Exception:
        continue

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
    # Silent allow path. Avoid adding model-visible context on every Bash call.
    print(json.dumps({"continue": True}))
PY_PRE
else
  cat "$input_file" >> "$log"
  printf '\n' >> "$log"
  printf '%s\n' '{"continue":true}'
fi
