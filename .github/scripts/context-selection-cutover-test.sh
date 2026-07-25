#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
CASE_MANIFEST="$MODEL_ROOT/testdata/context-selection-cutover-cases.json"
RUNTIME_CUE="$MODEL_ROOT/context_selection_cutover_runtime.cue"
CUE_BIN="${CONTEXT_SELECTION_CUE:-cue}"

work="$(mktemp -d "${TMPDIR:-/tmp}/context-selection-cutover.XXXXXX")"
cleanup() {
  rm -rf -- "$work"
  rm -f -- "$RUNTIME_CUE"
}
trap cleanup EXIT

cue_json() {
  (
    cd "$MODEL_ROOT"
    "$CUE_BIN" eval . -e "$1" --out json
  )
}

expect_failure() {
  local expression="$1"
  if cue_json "$expression" >"$work/unexpected-success.json" 2>"$work/expected-failure.err"; then
    echo "FAIL: expected CUE rejection: $expression" >&2
    return 1
  fi
}

write_committed_runtime() {
  cat >"$RUNTIME_CUE" <<'CUE'
package contextmodel

cutoverProjection: #GitCommittedSnapshotProjection & {
  observation: {
    schema: "kernel.git-committed-snapshot-observation.v0"
    repositoryID: "repository.fixture"
    requestedRevision: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    resolvedRevision: {format: "sha1", hex: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
    rootTree: {format: "sha1", hex: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"}
    occurrences: [
      {
        path: "src"
        mode: "040000"
        kind: "tree"
        objectID: {format: "sha1", hex: "cccccccccccccccccccccccccccccccccccccccc"}
      },
      {
        path: "src/main.py"
        mode: "100644"
        kind: "blob"
        size: 12
        objectID: {format: "sha1", hex: "dddddddddddddddddddddddddddddddddddddddd"}
      },
    ]
    hydrator: {
      identity: "hydrator.fixture"
      digest: "sha256:6666666666666666666666666666666666666666666666666666666666666666"
    }
  }
  schemaDigest: "sha256:7777777777777777777777777777777777777777777777777777777777777777"
  policyDigest: "sha256:8888888888888888888888888888888888888888888888888888888888888888"
}

cutoverRequest: #ContextApplicationRequest & {
  schema: "dotfiles.context-application-request.v0"
  requestID: "request.committed-cutover"
  repository: "repository.fixture"
  revision: "HEAD"
  allowedPaths: ["."]
  overlayMode: "disabled"
  roots: {
    memberIDs: []
    namespaceIDs: []
    pathPrefixes: ["src"]
  }
}

cutoverProposal: #ContextRootProposal & {
  schema: "dotfiles.context-root-proposal.v0"
  requestID: cutoverRequest.requestID
  snapshotID: cutoverProjection.graph.snapshotID
  memberIDs: []
  namespaceIDs: []
  pathPrefixes: []
}

cutoverPolicy: #ContextSelectionPolicy & {
  schema: "dotfiles.context-selection-policy.v0"
  predicates: ["contains"]
  limits: {}
}

cutoverEvaluation: #ContextCommittedSelectionEvaluation & {
  request: cutoverRequest
  proposal: cutoverProposal
  policy: cutoverPolicy
  committedProjection: cutoverProjection
}

cutoverOutsideRequest: #ContextApplicationRequest & {
  schema: "dotfiles.context-application-request.v0"
  requestID: "request.committed-cutover-outside"
  repository: "repository.fixture"
  revision: "HEAD"
  allowedPaths: ["src/main.py"]
  overlayMode: "disabled"
  roots: {
    memberIDs: []
    namespaceIDs: []
    pathPrefixes: ["src/main.py"]
  }
}

cutoverOutsideProposal: #ContextRootProposal & {
  schema: "dotfiles.context-root-proposal.v0"
  requestID: cutoverOutsideRequest.requestID
  snapshotID: cutoverProjection.graph.snapshotID
  memberIDs: []
  namespaceIDs: []
  pathPrefixes: []
}

_cutoverOutsideEvaluation: #ContextCommittedSelectionEvaluation & {
  request: cutoverOutsideRequest
  proposal: cutoverOutsideProposal
  policy: cutoverPolicy
  committedProjection: cutoverProjection
}
CUE
}

record_case() {
  local property_id="$1"
  printf '%s\n' "$property_id" >>"$work/executed-property-ids.txt"
}

run_case() {
  local property_id="$1"
  local case_id="$2"
  local output
  case "$case_id" in
    inside-boundary)
      cue_json 'contextSelectionCutoverFixtures.boundary.inside & {evaluation: #ContextSelectionRequestBoundary & contextSelectionCutoverFixtures.boundary.inside}' >/dev/null
      ;;
    outside-member)
      expect_failure 'contextSelectionCutoverFixtures.boundary.outsideMember & {evaluation: #ContextSelectionRequestBoundary & contextSelectionCutoverFixtures.boundary.outsideMember}'
      ;;
    outside-file)
      expect_failure 'contextSelectionCutoverFixtures.boundary.outsideFile & {evaluation: #ContextSelectionRequestBoundary & contextSelectionCutoverFixtures.boundary.outsideFile}'
      ;;
    repository-root-boundary)
      cue_json 'contextSelectionCutoverFixtures.boundary.repositoryRoot & {evaluation: #ContextSelectionRequestBoundary & contextSelectionCutoverFixtures.boundary.repositoryRoot}' >/dev/null
      ;;
    canonical-order)
      cue_json '{evaluation: #ContextSelectionCanonicalSurface & {proposal: contextSelectionCutoverFixtures.canonical.proposal, rootCatalog: contextSelectionCutoverFixtures.canonical.rootCatalog, proof: contextSelectionCutoverFixtures.canonical.proof, aliases: contextSelectionCutoverFixtures.canonical.aliases}}' >/dev/null
      ;;
    unsorted-proposal)
      expect_failure '{evaluation: #ContextSelectionCanonicalSurface & {proposal: contextSelectionCutoverFixtures.canonical.unsortedProposal, rootCatalog: contextSelectionCutoverFixtures.canonical.rootCatalog, proof: contextSelectionCutoverFixtures.canonical.proof, aliases: contextSelectionCutoverFixtures.canonical.aliases}}'
      ;;
    duplicate-evidence)
      expect_failure '{evaluation: #ContextSelectionCanonicalSurface & {proposal: contextSelectionCutoverFixtures.canonical.proposal, rootCatalog: contextSelectionCutoverFixtures.canonical.rootCatalog, proof: contextSelectionCutoverFixtures.canonical.duplicateEvidenceProof, aliases: contextSelectionCutoverFixtures.canonical.aliases}}'
      ;;
    empty-canonical-lists)
      cue_json '{evaluation: #ContextSelectionCanonicalSurface & {proposal: contextSelectionCutoverFixtures.canonical.emptyProposal, rootCatalog: contextSelectionCutoverFixtures.canonical.emptyRootCatalog, proof: contextSelectionCutoverFixtures.canonical.empty, aliases: contextSelectionCutoverFixtures.canonical.aliases}}' >/dev/null
      ;;
    committed-success|committed-single-file)
      write_committed_runtime
      output="$(cue_json cutoverEvaluation)"
      rm -f -- "$RUNTIME_CUE"
      jq -e '.packet.packet.selected.files == ["src/main.py"]' <<<"$output" >/dev/null
      jq -e '.proof.counters.files == 1 and .proof.counters.fileBytes == 12' <<<"$output" >/dev/null
      jq -e '.resolution.selection.sufficiency == "sufficient"' <<<"$output" >/dev/null
      ;;
    committed-outside-boundary)
      write_committed_runtime
      expect_failure _cutoverOutsideEvaluation
      rm -f -- "$RUNTIME_CUE"
      ;;
    *)
      echo "FAIL: no runner for property case: $property_id/$case_id" >&2
      return 1
      ;;
  esac
  record_case "$property_id"
}

printf '%s\n' "==> Export context-selection cutover property catalog"
cue_json contextSelectionCutoverPropertyCatalog >"$work/catalog.json"
jq -r '.properties | keys[]' "$work/catalog.json" | sort -u >"$work/declared.txt"
jq -r '.properties[].propertyID' "$CASE_MANIFEST" | sort -u >"$work/generated.txt"

printf '%s\n' "==> Verify cutover fixture strategies match the CUE catalog"
jq -S '[.properties | to_entries[] | {propertyID:.key,cases:([.value.strategies.positive[],.value.strategies.negative[],.value.strategies.boundary[]])}]' \
  "$work/catalog.json" >"$work/catalog-cases.json"
jq -S '.properties' "$CASE_MANIFEST" >"$work/manifest-cases.json"
cmp "$work/catalog-cases.json" "$work/manifest-cases.json"

: >"$work/executed-property-ids.txt"
while IFS=$'\t' read -r property_id case_id; do
  run_case "$property_id" "$case_id"
done < <(jq -r '.properties[] | .propertyID as $property | .cases[] | [$property,.] | @tsv' "$CASE_MANIFEST")
sort -u "$work/executed-property-ids.txt" >"$work/executed.txt"

jq -n \
  --rawfile declared "$work/declared.txt" \
  --rawfile generated "$work/generated.txt" \
  --rawfile executed "$work/executed.txt" \
  '{
    schema:"kernel.context-selection-cutover-qualification-report.v0",
    declaredPropertyIDs:($declared|split("\n")|map(select(length>0))),
    generatedPropertyIDs:($generated|split("\n")|map(select(length>0))),
    executedPropertyIDs:($executed|split("\n")|map(select(length>0))),
    reportedPropertyIDs:($executed|split("\n")|map(select(length>0))),
    propertyReport:{
      schema:"kernel.context-selection-cutover-property-report.v0",
      results:($executed|split("\n")|map(select(length>0))|map({propertyID:.,status:"passed"}))
    }
  }' >"$work/qualification-report.json"
jq -r '.reportedPropertyIDs[]' "$work/qualification-report.json" | sort -u >"$work/reported.txt"

for set_name in generated executed reported; do
  cmp "$work/declared.txt" "$work/$set_name.txt"
done
(
  cd "$MODEL_ROOT"
  "$CUE_BIN" vet -c -d '#ContextSelectionCutoverQualificationReport' . "$work/qualification-report.json"
)

printf '%s\n' "==> Context-selection cutover validation passed"
