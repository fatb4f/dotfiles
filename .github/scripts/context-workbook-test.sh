#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
WORKBOOK_ROOT="$REPO_ROOT/.codex/context-workbook"
DSPY_SERVICE_FIXTURES="$MODEL_ROOT/testdata/dspy-service-fixtures.json"
DSPY_SERVICE_REVIEW_REGRESSIONS="$MODEL_ROOT/testdata/dspy-service-review-regressions.json"
PYTHON_BIN="${CONTEXT_WORKBOOK_PYTHON:-python}"
export PYTHONPATH="$WORKBOOK_ROOT/src${PYTHONPATH:+:$PYTHONPATH}"
export CONTEXT_WORKBOOK_CUE="${CONTEXT_WORKBOOK_CUE:-cue}"

cd "$REPO_ROOT"

validate_dspy_contracts() (
  set -euo pipefail
  echo "==> Validate transport-neutral DSPy inference CUE fixtures"
  fixture_work="$(mktemp -d "${TMPDIR:-/tmp}/dspy-service-fixtures.XXXXXX")"
  trap 'rm -rf -- "$fixture_work"' EXIT

  "$PYTHON_BIN" - "$DSPY_SERVICE_FIXTURES" "$DSPY_SERVICE_REVIEW_REGRESSIONS" "$fixture_work" <<'PY2'
import copy
import json
import sys
from pathlib import Path

corpus_path = Path(sys.argv[1])
regressions_path = Path(sys.argv[2])
output_root = Path(sys.argv[3])
corpus = json.loads(corpus_path.read_text(encoding="utf-8"))
regressions = json.loads(regressions_path.read_text(encoding="utf-8"))
valid = corpus["valid"]
for name in ("completed", "failed"):
    (output_root / f"{name}.json").write_text(
        json.dumps(valid[name], sort_keys=True), encoding="utf-8"
    )
(output_root / "backend-config.json").write_text(
    json.dumps(valid["backendConfig"], sort_keys=True), encoding="utf-8"
)
surface_root = output_root / "execution-surfaces"
surface_root.mkdir()
for name, value in valid["executionSurfaces"].items():
    (surface_root / f"{name}.json").write_text(
        json.dumps(value, sort_keys=True), encoding="utf-8"
    )
invalid_exchange_root = output_root / "invalid-exchange"
invalid_exchange_root.mkdir()
for mutation in [
    *corpus["invalidMutations"],
    *regressions["invalidExchangeMutations"],
]:
    value = copy.deepcopy(valid["completed"])
    target = value
    for part in mutation["path"][:-1]:
        target = target[part]
    target[mutation["path"][-1]] = mutation["value"]
    (invalid_exchange_root / f"{mutation['name']}.json").write_text(
        json.dumps(value, sort_keys=True), encoding="utf-8"
    )
invalid_backend_root = output_root / "invalid-backend"
invalid_backend_root.mkdir()
for mutation in regressions["invalidBackendConfigMutations"]:
    value = copy.deepcopy(valid["backendConfig"])
    target = value
    for part in mutation["path"][:-1]:
        target = target[part]
    target[mutation["path"][-1]] = mutation["value"]
    (invalid_backend_root / f"{mutation['name']}.json").write_text(
        json.dumps(value, sort_keys=True), encoding="utf-8"
    )
invalid_surface_root = output_root / "invalid-surface"
invalid_surface_root.mkdir()
for mutation in regressions["invalidExecutionSurfaceMutations"]:
    value = copy.deepcopy(valid["executionSurfaces"][mutation["surface"]])
    target = value
    for part in mutation["path"][:-1]:
        target = target[part]
    target[mutation["path"][-1]] = mutation["value"]
    (invalid_surface_root / f"{mutation['name']}.json").write_text(
        json.dumps(value, sort_keys=True), encoding="utf-8"
    )
PY2

  "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyInferenceExchange' \
    "$MODEL_ROOT" "$fixture_work/completed.json"
  "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyInferenceExchange' \
    "$MODEL_ROOT" "$fixture_work/failed.json"
  "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyBackendConfig' \
    "$MODEL_ROOT" "$fixture_work/backend-config.json"
  for execution_surface in "$fixture_work"/execution-surfaces/*.json; do
    "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyExecutionSurfaceProjection' \
      "$MODEL_ROOT" "$execution_surface"
  done
  "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyProviderRoutingDocument' \
    "$MODEL_ROOT" "$REPO_ROOT/.codex/plugins/code-intel/reference/lsp/provider-routing.json"
  "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyToolRegistryDocument' \
    "$MODEL_ROOT" "$REPO_ROOT/.codex/plugins/code-intel/reference/mcp/tool-registry.json"
  "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyCodeIntelWorkflowDocument' \
    "$MODEL_ROOT" "$REPO_ROOT/.codex/plugins/code-intel/reference/workflows/lua-first/workflow.json"
  for invalid_fixture in "$fixture_work"/invalid-exchange/*.json; do
    if "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyInferenceExchange' \
      "$MODEL_ROOT" "$invalid_fixture" >/dev/null 2>&1; then
      echo "FAIL: invalid DSPy inference fixture passed: $invalid_fixture" >&2
      exit 1
    fi
  done
  for invalid_fixture in "$fixture_work"/invalid-backend/*.json; do
    if "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyBackendConfig' \
      "$MODEL_ROOT" "$invalid_fixture" >/dev/null 2>&1; then
      echo "FAIL: invalid DSPy backend config passed: $invalid_fixture" >&2
      exit 1
    fi
  done
  for invalid_fixture in "$fixture_work"/invalid-surface/*.json; do
    if "$CONTEXT_WORKBOOK_CUE" vet -c -d '#DspyExecutionSurfaceProjection' \
      "$MODEL_ROOT" "$invalid_fixture" >/dev/null 2>&1; then
      echo "FAIL: invalid DSPy execution surface passed: $invalid_fixture" >&2
      exit 1
    fi
  done
  echo "==> DSPy contract validation passed"
)

validate_python_workbook() {
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
  echo "==> Python/workbook validation passed"
}

validate_hook_paths() {
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
assert context["sufficiency"]["state"] == "insufficient"
assert context["sufficiency"]["blockingGapIDs"] == [
    "gap.context-root-proposal-required"
]
assert context["context"] is None
PY2

  echo "==> Exercise prompt-only CLI fail-closed path"
  fail_closed_error="${TMPDIR:-/tmp}/context-workbook-fail-closed.err"
  if env -u CONTEXT_WORKBOOK_RECORDED_DECISION \
    CONTEXT_WORKBOOK_PYTHON="$PYTHON_BIN" \
    sh "$WORKBOOK_ROOT/run-context-workbook" \
    --repo-root "$REPO_ROOT" \
    --prompt "No configured model" \
    --revision HEAD \
    --output state 2>"$fail_closed_error"; then
    echo "FAIL: prompt-only CLI request unexpectedly succeeded" >&2
    exit 1
  fi
  grep -Fq \
    -- "--request-file is required; prompt-only selection fails closed" \
    "$fail_closed_error"
  echo "==> Hook and fail-closed validation passed"
}

phase="${1:-all}"
case "$phase" in
  dspy)
    validate_dspy_contracts
    ;;
  python)
    validate_python_workbook
    ;;
  hook)
    validate_hook_paths
    ;;
  all)
    validate_dspy_contracts
    validate_python_workbook
    validate_hook_paths
    echo "==> Context workbook validation passed"
    ;;
  *)
    echo "unknown context-workbook validation phase: $phase" >&2
    exit 2
    ;;
esac
