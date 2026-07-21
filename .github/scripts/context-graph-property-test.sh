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

work="$(mktemp -d "${TMPDIR:-/tmp}/context-graph-properties.XXXXXX")"
cleanup() {
  rm -rf -- "$work"
}
trap cleanup EXIT

printf '%s\n' "==> Export CUE context graph property catalog"
"$CUE_BIN" export "$MODEL_ROOT" \
  -e contextGraphPropertyCatalog \
  --out json \
  --outfile "$work/context-properties.json"

printf '%s\n' "==> Export CUE context graph JSON Schemas"
"$CUE_BIN" def "$MODEL_ROOT" \
  -e '#ContextGraphSnapshot' \
  --out jsonschema \
  --outfile "$work/context-graph.schema.json"
"$CUE_BIN" def "$MODEL_ROOT" \
  -e '#ContextGraphResolution' \
  --out jsonschema \
  --outfile "$work/context-resolution.schema.json"

printf '%s\n' "==> Validate exported property catalog through Pydantic"
"$PYTHON_BIN" - "$work/context-properties.json" "$work/context-graph.schema.json" "$work/context-resolution.schema.json" <<'PY'
import json
import sys
from pathlib import Path

from context_workbook.context_graph_property_extensions import register_additional_mutators
from context_workbook.context_graph_properties import (
    ContextGraphPropertyCatalog,
    validate_property_coverage,
)

register_additional_mutators()
catalog = ContextGraphPropertyCatalog.model_validate_json(
    Path(sys.argv[1]).read_text(encoding="utf-8")
)
validate_property_coverage(catalog)

for schema_path in map(Path, sys.argv[2:]):
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    assert schema["$schema"] == "https://json-schema.org/draft/2020-12/schema"
    assert schema["type"] == "object"
PY

printf '%s\n' "==> Run CUE/Pydantic/Hypothesis property matrix"
"$PYTHON_BIN" -m pytest -q "$WORKBOOK_ROOT/tests/test_context_graph_properties.py"

printf '%s\n' "==> Context graph property validation passed"
