#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
WORKBOOK_ROOT="$REPO_ROOT/.codex/context-workbook"
PYTHON_BIN="${CONTEXT_GRAPH_PYTHON:-python}"
CUE_BIN="${CONTEXT_GRAPH_CUE:-cue}"

export PYTHONPATH="$WORKBOOK_ROOT/src${PYTHONPATH:+:$PYTHONPATH}"
export CONTEXT_GRAPH_REPO_ROOT="$REPO_ROOT"
export CONTEXT_GRAPH_MODEL_ROOT="$MODEL_ROOT"
export CONTEXT_GRAPH_CUE="$CUE_BIN"

work="$(mktemp -d "${TMPDIR:-/tmp}/context-graph-authority.XXXXXX")"
cleanup() {
  rm -rf -- "$work"
}
trap cleanup EXIT

printf '%s\n' "==> Export CUE evidence authority matrix"
"$CUE_BIN" export "$MODEL_ROOT" \
  -e contextEvidenceAuthorityMatrix \
  --out json \
  --outfile "$work/context-evidence-authority-matrix.json"

printf '%s\n' "==> Export kind-only transition JSON Schema"
"$CUE_BIN" def "$MODEL_ROOT" \
  -e '#ContextEvidenceKindOnlyTransition' \
  --out jsonschema \
  --outfile "$work/context-evidence-kind-transition.schema.json"

printf '%s\n' "==> Execute all CUE/Pydantic authority matrix cells"
"$PYTHON_BIN" - \
  "$work/context-evidence-authority-matrix.json" \
  "$work/context-evidence-kind-transition.schema.json" \
  "$work/context-evidence-authority-report.json" <<'PY'
import json
import sys
from pathlib import Path

from context_workbook.context_graph_authority import (
    EvidenceAuthorityMatrix,
    execute_authority_matrix,
)

matrix = EvidenceAuthorityMatrix.model_validate_json(
    Path(sys.argv[1]).read_text(encoding="utf-8")
)
schema = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
assert schema["$schema"] == "https://json-schema.org/draft/2020-12/schema"
assert schema["type"] == "object"

report = execute_authority_matrix(matrix)
Path(sys.argv[3]).write_text(
    json.dumps(report, sort_keys=True, separators=(",", ":")) + "\n",
    encoding="utf-8",
)
PY

printf '%s\n' "==> Run evidence authority metamorphic properties"
"$PYTHON_BIN" -m pytest -q "$WORKBOOK_ROOT/tests/test_context_graph_authority.py"

printf '%s\n' "==> Context graph authority validation passed"
