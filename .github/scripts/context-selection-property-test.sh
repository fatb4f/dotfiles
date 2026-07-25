#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
CASE_MANIFEST="$MODEL_ROOT/testdata/context-selection-property-cases.json"
CUE_BIN="${CONTEXT_SELECTION_CUE:-cue}"

work="$(mktemp -d "${TMPDIR:-/tmp}/context-selection-properties.XXXXXX")"
cleanup() {
  rm -rf -- "$work"
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

record_case() {
  local property_id="$1"
  local case_id="$2"
  printf '%s\t%s\n' "$property_id" "$case_id" >>"$work/executed-cases.tsv"
  printf '%s\n' "$property_id" >>"$work/executed-property-ids.txt"
}

run_case() {
  local property_id="$1"
  local case_id="$2"
  local expression output first_output second_output base_digest variant_digest
  case "$case_id" in
    outgoing-proof)
      expression='contextSelectionPropertyFixtures.relationshipOutgoing & {step: #ContextTraversalStep & contextSelectionPropertyFixtures.relationshipOutgoing}'
      output="$(cue_json "$expression")"
      jq -e '.step.records == [{entity:{kind:"member",id:"member.target"},distance:1,direction:"outgoing",predecessor:"rel.out"}]' <<<"$output" >/dev/null
      ;;
    lowest-incoming-proof)
      expression='contextSelectionPropertyFixtures.relationshipPredecessor & {step: #ContextTraversalStep & contextSelectionPropertyFixtures.relationshipPredecessor}'
      output="$(cue_json "$expression")"
      jq -e '.step.records == [{entity:{kind:"member",id:"member.target"},distance:1,direction:"incoming",predecessor:"rel.a.in"}]' <<<"$output" >/dev/null
      ;;
    relationship-order-perturbation)
      first_output="$(cue_json 'contextSelectionPropertyFixtures.relationshipOrderPerturbation.first & {step: #ContextTraversalStep & contextSelectionPropertyFixtures.relationshipOrderPerturbation.first}')"
      second_output="$(cue_json 'contextSelectionPropertyFixtures.relationshipOrderPerturbation.second & {step: #ContextTraversalStep & contextSelectionPropertyFixtures.relationshipOrderPerturbation.second}')"
      jq -S '.step.records' <<<"$first_output" >"$work/relationship-order-first.json"
      jq -S '.step.records' <<<"$second_output" >"$work/relationship-order-second.json"
      cmp "$work/relationship-order-first.json" "$work/relationship-order-second.json"
      ;;
    entity-id-predecessor)
      output="$(cue_json 'contextSelectionPropertyFixtures.relationshipPredecessor & {step: #ContextTraversalStep & contextSelectionPropertyFixtures.relationshipPredecessor}')"
      jq -e '.step.records[0].predecessor == "rel.a.in" and .step.records[0].predecessor != .previous[0].entity.id' <<<"$output" >/dev/null
      ;;
    parent-to-child)
      output="$(cue_json '{step: #ContextTraversalStep & {snapshot: contextSelectionPropertyFixtures.incomingAncestry.snapshot, predicates: ["contains"], previous: [{entity: {kind: "module", id: "module.fixture"}, distance: 0, direction: "root", predecessor: null}], visited: [{entity: {kind: "module", id: "module.fixture"}, distance: 0, direction: "root", predecessor: null}], distance: 1}}')"
      jq -e '.step.records == [{entity:{kind:"namespace",id:"namespace.fixture"},distance:1,direction:"outgoing",predecessor:"rel.contains-root"}]' <<<"$output" >/dev/null
      ;;
    non-contains-edge)
      output="$(cue_json 'contextSelectionPropertyFixtures.nonContains & {step: #ContextTraversalStep & contextSelectionPropertyFixtures.nonContains}')"
      jq -e '.step.records == []' <<<"$output" >/dev/null
      ;;
    child-to-parent)
      output="$(cue_json 'contextSelectionPropertyFixtures.incomingAncestry & {step: #ContextTraversalStep & contextSelectionPropertyFixtures.incomingAncestry & {distance: 1}}')"
      jq -e '.step.records == [{entity:{kind:"module",id:"module.fixture"},distance:1,direction:"incoming",predecessor:"rel.contains-root"}]' <<<"$output" >/dev/null
      ;;
    root-endpoint-reversal)
      output="$(cue_json 'contextSelectionPropertyFixtures.endpointReversed & {step: #ContextTraversalStep & contextSelectionPropertyFixtures.endpointReversed}')"
      jq -e '.step.records == [{entity:{kind:"namespace",id:"namespace.fixture"},distance:1,direction:"incoming",predecessor:"rel.reversed"}]' <<<"$output" >/dev/null
      ;;
    depth-eight-terminal)
      cue_json 'contextSelectionPropertyFixtures.depth.terminal & {completion: #ContextTraversalDepthCompletion & contextSelectionPropertyFixtures.depth.terminal}' >/dev/null
      ;;
    reachable-ninth-entity)
      expect_failure 'contextSelectionPropertyFixtures.depth.overflow & {completion: #ContextTraversalDepthCompletion & contextSelectionPropertyFixtures.depth.overflow}'
      ;;
    depth-eight-back-edge|visited-cycle-insertion)
      cue_json 'contextSelectionPropertyFixtures.depth.backEdge & {completion: #ContextTraversalDepthCompletion & contextSelectionPropertyFixtures.depth.backEdge}' >/dev/null
      ;;
    sixty-four-submissions)
      output="$(cue_json 'contextSelectionPropertyFixtures.rootCounting.count64 & {evaluation: #ContextRootSelectionEvaluation & contextSelectionPropertyFixtures.rootCounting.count64}')"
      jq -e '.evaluation.rootSpecificationCount == 64' <<<"$output" >/dev/null
      ;;
    sixty-five-submissions)
      expect_failure 'contextSelectionPropertyFixtures.rootCounting.count65 & {evaluation: #ContextRootSelectionEvaluation & contextSelectionPropertyFixtures.rootCounting.count65}'
      ;;
    one-prefix-sixty-five-seeds)
      output="$(cue_json 'contextSelectionPropertyFixtures.rootCounting.prefixExpansion & {evaluation: #ContextRootSelectionEvaluation & contextSelectionPropertyFixtures.rootCounting.prefixExpansion}')"
      jq -e '.evaluation.rootSpecificationCount == 1 and (.evaluation.roots | length) == 65' <<<"$output" >/dev/null
      ;;
    cross-source-duplicate)
      expect_failure 'contextSelectionPropertyFixtures.rootCounting.crossSourceDuplicate & {evaluation: #ContextRootSelectionEvaluation & contextSelectionPropertyFixtures.rootCounting.crossSourceDuplicate}'
      ;;
    superseded-exact-root|tombstone-exact-root)
      output="$(cue_json 'contextSelectionPropertyFixtures.forensicRoots.exact & {evaluation: #ContextRootSelectionEvaluation & contextSelectionPropertyFixtures.forensicRoots.exact}')"
      jq -e '(.evaluation.roots | keys | sort) == ["member:member.superseded","member:member.tombstone"]' <<<"$output" >/dev/null
      ;;
    tombstone-prefix-expansion)
      output="$(cue_json 'contextSelectionPropertyFixtures.forensicRoots.prefix & {evaluation: #ContextRootSelectionEvaluation & contextSelectionPropertyFixtures.forensicRoots.prefix}')"
      jq -e '(.evaluation.roots | keys) == ["member:member.effective"]' <<<"$output" >/dev/null
      ;;
    effective-winner-substitution)
      output="$(cue_json 'contextSelectionPropertyFixtures.forensicRoots.effectiveFiles & {evaluation: #ContextEffectiveFileSelection & contextSelectionPropertyFixtures.forensicRoots.effectiveFiles}')"
      jq -e '.evaluation.files == ["src/item"] and .evaluation.fileOccurrences["src/item"].memberID == "member.effective"' <<<"$output" >/dev/null
      ;;
    identical-input)
      output="$(cue_json 'contextSelectionPropertyFixtures.digest & {baseEvaluation: #ContextDigestEvaluation & contextSelectionPropertyFixtures.digest.base, identicalEvaluation: #ContextDigestEvaluation & contextSelectionPropertyFixtures.digest.identical}')"
      jq -e '.baseEvaluation.contextDigest == .identicalEvaluation.contextDigest' <<<"$output" >/dev/null
      ;;
    empty-projection-lists)
      output="$(cue_json 'contextSelectionPropertyFixtures.digest.base & {evaluation: #ContextDigestEvaluation & contextSelectionPropertyFixtures.digest.base}')"
      jq -e '.evaluation.envelope.relationshipIDs == [] and .evaluation.envelope.evidenceIDs == [] and .evaluation.envelope.evidenceAliases == []' <<<"$output" >/dev/null
      ;;
    unbound-component|each-envelope-component)
      base_digest="$(cue_json 'contextSelectionPropertyFixtures.digest.base & {evaluation: #ContextDigestEvaluation & contextSelectionPropertyFixtures.digest.base}' | jq -r '.evaluation.contextDigest')"
      for variant in request proposal policy effective-view traversal selected relationships evidence files aliases; do
        variant_digest="$(cue_json "contextSelectionPropertyFixtures.digest.\"$variant\" & {evaluation: #ContextDigestEvaluation & contextSelectionPropertyFixtures.digest.\"$variant\"}" | jq -r '.evaluation.contextDigest')"
        [[ "$variant_digest" != "$base_digest" ]]
      done
      ;;
    *)
      echo "FAIL: no runner for property case: $property_id/$case_id" >&2
      return 1
      ;;
  esac
  record_case "$property_id" "$case_id"
}

printf '%s\n' "==> Export context-selection property catalog"
cue_json contextSelectionPropertyCatalog >"$work/catalog.json"
jq -r '.properties | keys[]' "$work/catalog.json" | sort -u >"$work/declared.txt"
jq -r '.properties[].propertyID' "$CASE_MANIFEST" | sort -u >"$work/generated.txt"

printf '%s\n' "==> Verify generated fixture strategies match the CUE catalog"
jq -S '[.properties | to_entries[] | {propertyID:.key,cases:([.value.strategies.positive[],.value.strategies.negative[],.value.strategies.boundary[],.value.strategies.metamorphic[]])}]' \
  "$work/catalog.json" >"$work/catalog-cases.json"
jq -S '.properties' "$CASE_MANIFEST" >"$work/manifest-cases.json"
cmp "$work/catalog-cases.json" "$work/manifest-cases.json"

printf '%s\n' "==> Execute context-selection property cases"
: >"$work/executed-cases.tsv"
: >"$work/executed-property-ids.txt"
while IFS=$'\t' read -r property_id case_id; do
  run_case "$property_id" "$case_id"
done < <(jq -r '.properties[] | .propertyID as $property | .cases[] | [$property,.] | @tsv' "$CASE_MANIFEST")
sort -u "$work/executed-property-ids.txt" >"$work/executed.txt"

printf '%s\n' "==> Build and validate context-selection qualification report"
jq -n \
  --rawfile declared "$work/declared.txt" \
  --rawfile generated "$work/generated.txt" \
  --rawfile executed "$work/executed.txt" \
  '{
    schema:"kernel.context-selection-qualification-report.v0",
    declaredPropertyIDs:($declared|split("\n")|map(select(length>0))),
    generatedPropertyIDs:($generated|split("\n")|map(select(length>0))),
    executedPropertyIDs:($executed|split("\n")|map(select(length>0))),
    reportedPropertyIDs:($executed|split("\n")|map(select(length>0))),
    propertyReport:{
      schema:"kernel.context-selection-property-report.v0",
      results:($executed|split("\n")|map(select(length>0))|map({propertyID:.,status:"passed"}))
    }
  }' >"$work/qualification-report.json"
jq -r '.reportedPropertyIDs[]' "$work/qualification-report.json" | sort -u >"$work/reported.txt"

for set_name in generated executed reported; do
  cmp "$work/declared.txt" "$work/$set_name.txt"
done
(
  cd "$MODEL_ROOT"
  "$CUE_BIN" vet -c -d '#ContextSelectionQualificationReport' . "$work/qualification-report.json"
)

printf '%s\n' "==> Context-selection property validation passed"
