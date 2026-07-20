#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORKBOOK_ROOT="$REPO_ROOT/.codex/context-workbook"
PYTHON_BIN="${CONTEXT_WORKBOOK_PYTHON:-python}"
export PYTHONPATH="$WORKBOOK_ROOT/src${PYTHONPATH:+:$PYTHONPATH}"
export CONTEXT_WORKBOOK_CUE="${CONTEXT_WORKBOOK_CUE:-cue}"

cd "$REPO_ROOT"

echo "==> Compile context workbook"
"$PYTHON_BIN" -m compileall -q "$WORKBOOK_ROOT"

echo "==> Run context workbook unit tests"
"$PYTHON_BIN" -m unittest discover -s "$WORKBOOK_ROOT/tests" -v

echo "==> Check deterministic plugin projections"
"$PYTHON_BIN" -m context_workbook.projections --repo-root "$REPO_ROOT" --check

echo "==> Prove legacy lexical routing is absent"
if grep -E 'ascii_downcase|promptRoutes|contains\(\$term\)' \
  "$REPO_ROOT/.codex/plugins/agent-context-resolver/scripts/agent-context-resolver-hook" \
  "$REPO_ROOT/.codex/plugins/agent-context-resolver/scripts/resolve-agent-context"; then
  echo "FAIL: legacy lexical routing remains in resolver adapters" >&2
  exit 1
fi

echo "==> Exercise resolver hook through the canonical workbook"
fixture="$WORKBOOK_ROOT/tests/fixtures/sufficient-decision.json"
hook_output="$({
  printf '%s\n' '{"hook_event_name":"UserPromptSubmit","prompt":"Implement Issue 54"}'
} | CONTEXT_WORKBOOK_PYTHON="$PYTHON_BIN" \
    CONTEXT_WORKBOOK_TEST_MODE=1 \
    CONTEXT_WORKBOOK_RECORDED_DECISION="$fixture" \
    "$REPO_ROOT/.codex/plugins/agent-context-resolver/scripts/agent-context-resolver-hook")"

HOOK_OUTPUT="$hook_output" "$PYTHON_BIN" - <<'PY'
import json
import os
value = json.loads(os.environ["HOOK_OUTPUT"])
assert value["hookSpecificOutput"]["hookEventName"] == "UserPromptSubmit"
context = json.loads(value["hookSpecificOutput"]["additionalContext"])
assert context["schema"] == "agent.resolver-prompt-surface.v2"
assert context["sufficiency"]["state"] == "sufficient"
assert context["context"]["schema"] == "dotfiles.context-packet.v0"
PY

echo "==> Exercise production fail-closed path without a configured DSPy LM"
env -u CONTEXT_WORKBOOK_DSPY_MODEL \
  -u CONTEXT_WORKBOOK_RECORDED_DECISION \
  CONTEXT_WORKBOOK_PYTHON="$PYTHON_BIN" \
  "$WORKBOOK_ROOT/run-context-workbook" \
  --repo-root "$REPO_ROOT" \
  --prompt "No configured model" \
  --revision HEAD \
  --output state >"${TMPDIR:-/tmp}/context-workbook-fail-closed.json"

FAIL_CLOSED_PATH="${TMPDIR:-/tmp}/context-workbook-fail-closed.json" "$PYTHON_BIN" - <<'PY'
import json
import os
from pathlib import Path
path = Path(os.environ["FAIL_CLOSED_PATH"])
value = json.loads(path.read_text())
assert value["sufficiency"]["state"] == "insufficient"
assert value.get("projection") is None
assert value["sufficiency"]["blockingGapIDs"] == ["gap.dspy-unavailable"]
PY

echo "==> Context workbook validation passed"
