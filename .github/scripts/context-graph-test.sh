#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
FIXTURES="$MODEL_ROOT/testdata/context-graph-fixtures.json"
PYTHON_BIN="${CONTEXT_GRAPH_PYTHON:-python}"
CUE_BIN="${CONTEXT_GRAPH_CUE:-cue}"

work="$(mktemp -d "${TMPDIR:-/tmp}/context-graph-fixtures.XXXXXX")"
cleanup() {
  rm -rf -- "$work"
}
trap cleanup EXIT

"$PYTHON_BIN" - "$FIXTURES" "$work" <<'PY'
import copy
import json
import sys
from pathlib import Path

corpus_path = Path(sys.argv[1])
output_root = Path(sys.argv[2])
corpus = json.loads(corpus_path.read_text(encoding="utf-8"))
valid = corpus["valid"]
snapshot = valid["snapshot"]
selection = valid["selection"]
resolution = {
    "schema": "kernel.context-resolution.v0",
    "snapshot": snapshot,
    "selection": selection,
}

(output_root / "snapshot.json").write_text(
    json.dumps(snapshot, sort_keys=True), encoding="utf-8"
)
(output_root / "resolution.json").write_text(
    json.dumps(resolution, sort_keys=True), encoding="utf-8"
)

invalid_root = output_root / "invalid"
invalid_root.mkdir()
for mutation in corpus["invalidMutations"]:
    definition = (
        "#ContextGraphSnapshot"
        if mutation["target"] == "snapshot"
        else "#ContextGraphResolution"
    )
    value = copy.deepcopy(snapshot if mutation["target"] == "snapshot" else resolution)
    target = value
    for part in mutation["path"][:-1]:
        target = target[part]
    target[mutation["path"][-1]] = mutation["value"]
    payload = {
        "definition": definition,
        "value": value,
    }
    (invalid_root / f"{mutation['name']}.json").write_text(
        json.dumps(payload, sort_keys=True), encoding="utf-8"
    )
PY

echo "==> Validate normalized repository context graph"
"$CUE_BIN" vet -c -d '#ContextGraphSnapshot' \
  "$MODEL_ROOT" "$work/snapshot.json"
"$CUE_BIN" vet -c -d '#ContextGraphResolution' \
  "$MODEL_ROOT" "$work/resolution.json"

for envelope in "$work"/invalid/*.json; do
  definition="$($PYTHON_BIN -c 'import json,sys; print(json.load(open(sys.argv[1]))["definition"])' "$envelope")"
  value_path="$work/$(basename "$envelope" .json)-value.json"
  "$PYTHON_BIN" - "$envelope" "$value_path" <<'PY'
import json
import sys
from pathlib import Path

envelope = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
Path(sys.argv[2]).write_text(
    json.dumps(envelope["value"], sort_keys=True), encoding="utf-8"
)
PY
  if "$CUE_BIN" vet -c -d "$definition" \
    "$MODEL_ROOT" "$value_path" >/dev/null 2>&1; then
    echo "FAIL: invalid context graph fixture passed: $envelope" >&2
    exit 1
  fi
done

echo "==> Context graph validation passed"
