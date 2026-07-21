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

work="$(mktemp -d "${TMPDIR:-/tmp}/context-graph-admission.XXXXXX")"
cleanup() {
  rm -rf -- "$work"
}
trap cleanup EXIT

printf '%s\n' "==> Export CUE evidence admission matrix"
"$CUE_BIN" export "$MODEL_ROOT" \
  -e contextEvidenceAdmissionMatrix \
  --out json \
  --outfile "$work/context-evidence-admission-matrix.json"

printf '%s\n' "==> Export admission JSON Schemas"
for definition in \
  '#ContextEvidenceAuthorityState' \
  '#ContextCollectedEvidenceEnvelope' \
  '#ContextEvidenceAdmissionRecord' \
  '#ContextEvidenceNoAdmissionTransition' \
  '#ContextEvidenceAdmissionTransition' \
  '#ContextEvidenceAuthorityProjection' \
  '#ContextEvidenceAdmissionBundle'; do
  name="${definition#\#}"
  "$CUE_BIN" def "$MODEL_ROOT" \
    -e "$definition" \
    --out jsonschema \
    --outfile "$work/$name.schema.json"
done

printf '%s\n' "==> Execute admission matrix and transport rejection cases"
"$PYTHON_BIN" - \
  "$work/context-evidence-admission-matrix.json" \
  "$work" \
  "$work/context-evidence-admission-report.json" \
  "$work/context-evidence-unknown-field-report.json" <<'PY'
import json
import sys
from pathlib import Path

from context_workbook.context_graph_admission import (
    EvidenceAdmissionMatrix,
    TRANSPORT_MODELS,
    execute_admission_matrix,
    execute_transport_unknown_field_cases,
)

matrix = EvidenceAdmissionMatrix.model_validate_json(
    Path(sys.argv[1]).read_text(encoding="utf-8")
)
schema_root = Path(sys.argv[2])
schema_paths = sorted(schema_root.glob("Context*.schema.json"))
assert len(schema_paths) == len(TRANSPORT_MODELS)
for path in schema_paths:
    schema = json.loads(path.read_text(encoding="utf-8"))
    assert schema["$schema"] == "https://json-schema.org/draft/2020-12/schema"
    assert schema["type"] == "object"

admission_report = execute_admission_matrix(matrix)
Path(sys.argv[3]).write_text(
    json.dumps(admission_report, sort_keys=True, separators=(",", ":")) + "\n",
    encoding="utf-8",
)

unknown_field_report = execute_transport_unknown_field_cases()
Path(sys.argv[4]).write_text(
    json.dumps(unknown_field_report, sort_keys=True, separators=(",", ":")) + "\n",
    encoding="utf-8",
)
PY

printf '%s\n' "==> Run evidence admission metamorphic properties"
"$PYTHON_BIN" -m pytest -q "$WORKBOOK_ROOT/tests/test_context_graph_admission.py"

printf '%s\n' "==> Context graph admission validation passed"
