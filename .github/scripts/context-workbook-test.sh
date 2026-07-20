#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
WORKBOOK_ROOT="$REPO_ROOT/.codex/context-workbook"
DSPY_SERVICE_FIXTURES="$MODEL_ROOT/testdata/dspy-service-fixtures.json"
PYTHON_BIN="${CONTEXT_WORKBOOK_PYTHON:-python}"
export PYTHONPATH="$WORKBOOK_ROOT/src${PYTHONPATH:+:$PYTHONPATH}"
export CONTEXT_WORKBOOK_CUE="${CONTEXT_WORKBOOK_CUE:-cue}"

cd "$REPO_ROOT"

echo "==> Validate DSPy service CUE transport fixtures"
fixture_work="$(mktemp -d "${TMPDIR:-/tmp}/dspy-service-fixtures.XXXXXX")"
cleanup_fixture_work() {
  rm -rf -- "$fixture_work"
}
trap cleanup_fixture_work EXIT

"$PYTHON_BIN" - "$DSPY_SERVICE_FIXTURES" "$fixture_work" <<'PY2'
import json
import sys
from pathlib import Path

corpus_path = Path(sys.argv[1])
output_root = Path(sys.argv[2])
corpus = json.loads(corpus_path.read_text(encoding="utf-8"))
valid = corpus["valid"]
for name in ("completed", "failed"):
    (output_root / f"{name}.json").write_text(
        json.dumps(valid[name], sort_keys=True), encoding="utf-8"
    )
(output_root / "service-config.json").write_text(
    json.dumps(valid["serviceConfig"], sort_keys=True), encoding="utf-8"
)
invalid_root = output_root / "invalid"
invalid_root.mkdir()
for mutation in corpus["invalidMutations"]:
    value = json.loads(json.dumps(valid["completed"]))
    target = value
    for part in mutation["path"][:-1]:
        target = target[part]
    target[mutation["path"][-1]] = mutation["value"]
    (invalid_root / f"{mutation['name']}.json").write_text(
        json.dumps(value, sort_keys=True), encoding="utf-8"
    )
PY2

"$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyInferenceExchange' \
  "$MODEL_ROOT" "$fixture_work/completed.json"
"$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyInferenceExchange' \
  "$MODEL_ROOT" "$fixture_work/failed.json"
"$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyServiceConfig' \
  "$MODEL_ROOT" "$fixture_work/service-config.json"
for invalid_fixture in "$fixture_work"/invalid/*.json; do
  if "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyInferenceExchange' \
    "$MODEL_ROOT" "$invalid_fixture" >/dev/null 2>&1; then
    echo "FAIL: invalid DSPy service fixture passed: $invalid_fixture" >&2
    exit 1
  fi
done

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

HOOK_OUTPUT="$hook_output" "$PYTHON_BIN" - <<'PY2'
import json
import os
value = json.loads(os.environ["HOOK_OUTPUT"])
assert value["hookSpecificOutput"]["hookEventName"] == "UserPromptSubmit"
context = json.loads(value["hookSpecificOutput"]["additionalContext"])
assert context["schema"] == "agent.resolver-prompt-surface.v2"
assert context["sufficiency"]["state"] == "sufficient"
assert context["context"]["schema"] == "dotfiles.context-packet.v0"
PY2

echo "==> Exercise production fail-closed path without an available Codex CLI"
env -u CONTEXT_WORKBOOK_RECORDED_DECISION \
  CONTEXT_WORKBOOK_DSPY_MODEL=codex/gpt-5.6-sol \
  CONTEXT_WORKBOOK_CODEX=/nonexistent/context-workbook-codex \
  CONTEXT_WORKBOOK_PYTHON="$PYTHON_BIN" \
  sh "$WORKBOOK_ROOT/run-context-workbook" \
  --repo-root "$REPO_ROOT" \
  --prompt "No configured model" \
  --revision HEAD \
  --output state >"${TMPDIR:-/tmp}/context-workbook-fail-closed.json"

FAIL_CLOSED_PATH="${TMPDIR:-/tmp}/context-workbook-fail-closed.json" "$PYTHON_BIN" - <<'PY2'
import json
import os
from pathlib import Path
path = Path(os.environ["FAIL_CLOSED_PATH"])
value = json.loads(path.read_text())
assert value["sufficiency"]["state"] == "insufficient"
assert value.get("projection") is None
assert value["sufficiency"]["blockingGapIDs"] == ["gap.dspy-unavailable"]
PY2

echo "==> Context workbook validation passed"
