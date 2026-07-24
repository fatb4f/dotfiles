#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HYDRATOR_ROOT="$REPO_ROOT/.codex/context-hydrators/git"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
WORK_DIR="$(mktemp -d)"
QUALIFICATION_DIR="${CONTEXT_GIT_OVERLAY_QUALIFICATION_DIR:-${TMPDIR:-/tmp}/context-git-overlay-qualification}"
PROJECTION_CUE="$MODEL_ROOT/git_overlay_qualification.cue"
trap 'rm -rf "$WORK_DIR"; rm -f "$PROJECTION_CUE"' EXIT
mkdir -p "$QUALIFICATION_DIR"

HYDRATOR_BUILD_DIGEST="$(python - "$HYDRATOR_ROOT" <<'PY'
from __future__ import annotations
import hashlib
import sys
from pathlib import Path
root = Path(sys.argv[1]).resolve()
digest = hashlib.sha256()
for path in sorted(
    p for p in root.rglob("*")
    if p.is_file() and (p.suffix == ".go" or p.name in {"go.mod", "go.sum"})
):
    relative = path.relative_to(root).as_posix().encode()
    digest.update(relative)
    digest.update(b"\0")
    digest.update(path.read_bytes())
    digest.update(b"\0")
print("sha256:" + digest.hexdigest())
PY
)"
HYDRATOR_LDFLAGS="-X github.com/fatb4f/dotfiles/.codex/context-hydrators/git/internal/hydrator.BuildHydratorDigest=$HYDRATOR_BUILD_DIGEST"
PROPERTY_REPORT="$QUALIFICATION_DIR/property-report.json"
QUALIFICATION_REPORT="$QUALIFICATION_DIR/qualification-report.json"
GO_TEST_LOG="$WORK_DIR/go-test.jsonl"
rm -f "$PROPERTY_REPORT" "$QUALIFICATION_REPORT"

printf '%s\n' "==> Run overlay Go typed-model, adapter, property, and metamorphic tests"
(
  cd "$HYDRATOR_ROOT"
  go mod download
  go mod verify
  CONTEXT_GIT_OVERLAY_PROPERTY_REPORT="$PROPERTY_REPORT" \
    go test -count=1 -json ./... | tee "$GO_TEST_LOG"
  git diff --exit-code -- go.mod go.sum
  go build -trimpath -ldflags "$HYDRATOR_LDFLAGS" -o "$WORK_DIR/context-git-hydrator" ./cmd/context-git-hydrator
  go run ./internal/testfixture/cmd/context-git-fixture --output "$WORK_DIR/fixture-one"
  go run ./internal/testfixture/cmd/context-git-fixture --output "$WORK_DIR/fixture-two"
)
test -s "$PROPERTY_REPORT"

MANIFEST="$WORK_DIR/fixture-one/manifest.json"
OVERLAY_MANIFEST="$WORK_DIR/fixture-one/overlay-manifest.json"
BASE_REVISION="$(jq -er '.repository.commits.F' "$MANIFEST")"
BASE_REVISION_A="$(jq -er '.repository.commits.A' "$MANIFEST")"
SCHEMA_DIGEST="sha256:1111111111111111111111111111111111111111111111111111111111111111"
POLICY_DIGEST="sha256:2222222222222222222222222222222222222222222222222222222222222222"

make_overlay_request() {
  local target="$1"
  local repository_path="$2"
  local revision="$3"
  jq -n \
    --arg repositoryID "repo.fixture" \
    --arg path "$repository_path" \
    --arg revision "$revision" \
    '{schema:"kernel.git-overlay-request.v0",repositoryID:$repositoryID,path:$path,baseRevision:{format:"sha1",hex:$revision}}' \
    >"$target"
}

make_committed_request() {
  local target="$1"
  local repository_path="$2"
  jq -n \
    --arg repositoryID "repo.fixture" \
    --arg path "$repository_path" \
    --arg revision "$BASE_REVISION" \
    '{schema:"kernel.git-committed-snapshot-request.v0",repositoryID:$repositoryID,path:$path,revision:$revision}' \
    >"$target"
}

project_committed() {
  local observation="$1"
  local target="$2"
  {
    printf '%s\n' 'package contextmodel'
    printf '%s\n' 'overlayBaseProjection: #GitCommittedSnapshotProjection & {'
    printf '%s\n' '  observation:'
    sed 's/^/  /' "$observation"
    printf '%s\n' "  schemaDigest: \"$SCHEMA_DIGEST\""
    printf '%s\n' "  policyDigest: \"$POLICY_DIGEST\""
    printf '%s\n' '}'
  } >"$PROJECTION_CUE"
  (
    cd "$MODEL_ROOT"
    cue export . -e overlayBaseProjection --out json >"$target"
    cue vet . "$target" -d '#GitCommittedSnapshotProjection'
  )
  rm -f "$PROJECTION_CUE"
}

project_overlay() {
  local committed="$1"
  local observation="$2"
  local target="$3"
  {
    printf '%s\n' 'package contextmodel'
    printf '%s\n' 'overlayQualificationProjection: #GitOverlayProjection & {'
    printf '%s\n' '  committed:'
    sed 's/^/  /' "$committed"
    printf '%s\n' '  observation:'
    sed 's/^/  /' "$observation"
    printf '%s\n' "  schemaDigest: \"$SCHEMA_DIGEST\""
    printf '%s\n' "  policyDigest: \"$POLICY_DIGEST\""
    printf '%s\n' '}'
  } >"$PROJECTION_CUE"
  (
    cd "$MODEL_ROOT"
    cue export . -e overlayQualificationProjection --out json >"$target"
    cue vet . "$target" -d '#GitOverlayProjection'
  )
  rm -f "$PROJECTION_CUE"
}

printf '%s\n' "==> Qualify a clean overlay and byte-identical committed graph projection"
make_committed_request "$WORK_DIR/committed-request.json" "repository"
make_overlay_request "$WORK_DIR/clean-overlay-request.json" "repository" "$BASE_REVISION"
(
  cd "$WORK_DIR/fixture-one"
  "$WORK_DIR/context-git-hydrator" committed --request "$WORK_DIR/committed-request.json" >"$WORK_DIR/committed-observation.json"
  "$WORK_DIR/context-git-hydrator" overlay --request "$WORK_DIR/clean-overlay-request.json" >"$WORK_DIR/clean-overlay-observation.json"
)
(
  cd "$MODEL_ROOT"
  cue vet . "$WORK_DIR/clean-overlay-observation.json" -d '#GitOverlayObservation'
)
jq -e '(.index.occurrences | length) == 0 and (.worktree.occurrences | length) == 0' "$WORK_DIR/clean-overlay-observation.json" >/dev/null
project_committed "$WORK_DIR/committed-observation.json" "$WORK_DIR/committed-projection.json"
project_overlay "$WORK_DIR/committed-projection.json" "$WORK_DIR/clean-overlay-observation.json" "$WORK_DIR/clean-overlay-projection.json"
jq -S '.graph' "$WORK_DIR/committed-projection.json" >"$WORK_DIR/committed-graph.json"
jq -S '.graph' "$WORK_DIR/clean-overlay-projection.json" >"$WORK_DIR/clean-overlay-graph.json"
cmp "$WORK_DIR/committed-graph.json" "$WORK_DIR/clean-overlay-graph.json"

apply_overlay_state() {
  local repository="$1"
  local order="$2"
  if [[ "$order" == "reverse" ]]; then
    mkdir -p "$repository/vendor/overlay"
    git -C "$repository" update-index --add --cacheinfo "160000,$BASE_REVISION_A,vendor/overlay"
    ln -s untracked.txt "$repository/overlay-link"
    git -C "$repository" add overlay-link
    printf '%s\n' untracked >"$repository/untracked.txt"
    rm "$repository/guide-link"
    chmod 0644 "$repository/src/main.sh"
    git -C "$repository" add src/main.sh
    git -C "$repository" rm -f unrelated.txt
    printf '%s\n' 'staged addition' >"$repository/staged-add.txt"
    git -C "$repository" add staged-add.txt
    printf '%s\n' 'staged guide' >"$repository/docs/guide.txt"
    git -C "$repository" add docs/guide.txt
    printf '%s\n' 'unstaged guide' >"$repository/docs/guide.txt"
  else
    printf '%s\n' 'staged guide' >"$repository/docs/guide.txt"
    git -C "$repository" add docs/guide.txt
    printf '%s\n' 'unstaged guide' >"$repository/docs/guide.txt"
    printf '%s\n' 'staged addition' >"$repository/staged-add.txt"
    git -C "$repository" add staged-add.txt
    git -C "$repository" rm -f unrelated.txt
    chmod 0644 "$repository/src/main.sh"
    git -C "$repository" add src/main.sh
    rm "$repository/guide-link"
    printf '%s\n' untracked >"$repository/untracked.txt"
    ln -s untracked.txt "$repository/overlay-link"
    git -C "$repository" add overlay-link
    mkdir -p "$repository/vendor/overlay"
    git -C "$repository" update-index --add --cacheinfo "160000,$BASE_REVISION_A,vendor/overlay"
  fi
}

printf '%s\n' "==> Collect staged, unstaged, untracked, mode, symlink, and gitlink occurrences"
apply_overlay_state "$WORK_DIR/fixture-one/repository" forward
apply_overlay_state "$WORK_DIR/fixture-two/repository" reverse
make_overlay_request "$WORK_DIR/dirty-overlay-request-one.json" "repository" "$BASE_REVISION"
make_overlay_request "$WORK_DIR/dirty-overlay-request-two.json" "repository" "$BASE_REVISION"
(
  cd "$WORK_DIR/fixture-one"
  TZ=UTC LC_ALL=C LANG=C "$WORK_DIR/context-git-hydrator" overlay --request "$WORK_DIR/dirty-overlay-request-one.json" >"$WORK_DIR/dirty-overlay-one.json"
)
(
  cd "$WORK_DIR/fixture-two"
  TZ=Pacific/Kiritimati LC_ALL=C LANG=C "$WORK_DIR/context-git-hydrator" overlay --request "$WORK_DIR/dirty-overlay-request-two.json" >"$WORK_DIR/dirty-overlay-two.json"
)
cmp "$WORK_DIR/dirty-overlay-one.json" "$WORK_DIR/dirty-overlay-two.json"
if grep -F "$WORK_DIR/fixture-one/repository" "$WORK_DIR/dirty-overlay-one.json"; then
  echo "FAIL: overlay observation leaked the host repository path" >&2
  exit 1
fi
(
  cd "$MODEL_ROOT"
  cue vet . "$WORK_DIR/dirty-overlay-one.json" -d '#GitOverlayObservation'
)
jq -e '
  any(.index.occurrences[]; .path == "staged-add.txt" and .status == "added") and
  any(.index.occurrences[]; .path == "docs/guide.txt" and .status == "modified") and
  any(.index.occurrences[]; .path == "unrelated.txt" and .status == "deleted" and (has("objectID") | not)) and
  any(.index.occurrences[]; .path == "src/main.sh" and .modeChanged == true and .mode == "100644") and
  any(.index.occurrences[]; .path == "overlay-link" and .kind == "symlink") and
  any(.index.occurrences[]; .path == "vendor/overlay" and .kind == "submodule") and
  any(.worktree.occurrences[]; .path == "docs/guide.txt" and .status == "modified") and
  any(.worktree.occurrences[]; .path == "guide-link" and .status == "deleted" and (has("objectID") | not)) and
  any(.worktree.occurrences[]; .path == "untracked.txt" and .status == "untracked") and
  (any(.index.occurrences[]; .path == "untracked.txt") | not)
' "$WORK_DIR/dirty-overlay-one.json" >/dev/null

project_overlay "$WORK_DIR/committed-projection.json" "$WORK_DIR/dirty-overlay-one.json" "$WORK_DIR/dirty-overlay-projection.json"
jq -e '
  [.graph.evidence[] | select(.source.kind == "git-index-overlay" or .source.kind == "git-worktree-overlay") | .authority] |
  length == 2 and all(. == "candidate")
' "$WORK_DIR/dirty-overlay-projection.json" >/dev/null

expect_cue_reject() {
  local definition="$1"
  local document="$2"
  if (cd "$MODEL_ROOT" && cue vet . "$document" -d "$definition" >/dev/null 2>&1); then
    echo "FAIL: CUE accepted negative overlay fixture $document as $definition" >&2
    exit 1
  fi
}

printf '%s\n' "==> Execute overlay structural and authority rejection matrix"
jq '.unknown = true' "$WORK_DIR/dirty-overlay-one.json" >"$WORK_DIR/negative-unknown.json"
jq '.index.occurrences += [.index.occurrences[0]] | .index.occurrences |= sort_by(.path)' "$WORK_DIR/dirty-overlay-one.json" >"$WORK_DIR/negative-duplicate-index.json"
jq '.worktree.occurrences += [.worktree.occurrences[0]] | .worktree.occurrences |= sort_by(.path)' "$WORK_DIR/dirty-overlay-one.json" >"$WORK_DIR/negative-duplicate-worktree.json"
jq '.index.occurrences |= reverse' "$WORK_DIR/dirty-overlay-one.json" >"$WORK_DIR/negative-unsorted.json"
jq '(.index.occurrences[] | select(.status != "deleted") | .mode) = "160000"' "$WORK_DIR/dirty-overlay-one.json" >"$WORK_DIR/negative-mode.json"
jq '.index.occurrences[0].path = "docs/../escape"' "$WORK_DIR/dirty-overlay-one.json" >"$WORK_DIR/negative-path.json"
jq --arg revision "$BASE_REVISION_A" '.worktree.baseRevision.hex = $revision' "$WORK_DIR/dirty-overlay-one.json" >"$WORK_DIR/negative-layer-base.json"
jq '(.index.occurrences[] | select(.status == "deleted")) += {mode:"100644",kind:"blob",objectID:{format:"sha1",hex:"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}}' "$WORK_DIR/dirty-overlay-one.json" >"$WORK_DIR/negative-deletion-content.json"
for negative in unknown duplicate-index duplicate-worktree unsorted mode path layer-base deletion-content; do
  expect_cue_reject '#GitOverlayObservation' "$WORK_DIR/negative-$negative.json"
  if "$WORK_DIR/context-git-hydrator" validate-overlay-observation --observation "$WORK_DIR/negative-$negative.json" >/dev/null 2>&1; then
    echo "FAIL: typed overlay adapter accepted $negative mutation" >&2
    exit 1
  fi
done

jq '.collected.index.state.effectiveAuthority = "controller"' "$WORK_DIR/dirty-overlay-projection.json" >"$WORK_DIR/negative-authority.json"
expect_cue_reject '#GitOverlayProjection' "$WORK_DIR/negative-authority.json"
jq --arg revision "$BASE_REVISION_A" '.observation.baseRevision.hex = $revision | .observation.index.baseRevision.hex = $revision | .observation.worktree.baseRevision.hex = $revision' "$WORK_DIR/dirty-overlay-projection.json" >"$WORK_DIR/negative-projection-base.json"
expect_cue_reject '#GitOverlayProjection' "$WORK_DIR/negative-projection-base.json"

make_overlay_request "$WORK_DIR/wrong-base-request.json" "repository" "$BASE_REVISION_A"
if (cd "$WORK_DIR/fixture-one" && "$WORK_DIR/context-git-hydrator" overlay --request "$WORK_DIR/wrong-base-request.json" >/dev/null 2>&1); then
  echo "FAIL: collector accepted an overlay request bound to a non-HEAD base" >&2
  exit 1
fi

printf '%s\n' "==> Verify overlay declared/generated/executed/reported equality"
(
  cd "$MODEL_ROOT"
  cue export . -e gitOverlayProperties --out json >"$WORK_DIR/declared-properties.json"
)
jq -r 'keys[]' "$WORK_DIR/declared-properties.json" | sort >"$WORK_DIR/declared.txt"
jq -r '.properties[]' "$OVERLAY_MANIFEST" | sort >"$WORK_DIR/generated.txt"
jq -r \
  'select(.Action == "pass" and ((.Test // "") | startswith("TestOverlayDeclaredGeneratedExecutedReportedPropertySetEquality/execute/"))) | .Test | split("/execute/")[1]' \
  "$GO_TEST_LOG" | sort >"$WORK_DIR/executed.txt"
jq -e 'all(.results[]; .status == "passed")' "$PROPERTY_REPORT" >/dev/null
jq -r '.results[].propertyID' "$PROPERTY_REPORT" | sort >"$WORK_DIR/reported.txt"
for set_file in declared generated executed reported; do
  if [[ ! -s "$WORK_DIR/$set_file.txt" ]] || [[ -n "$(uniq -d "$WORK_DIR/$set_file.txt")" ]]; then
    echo "FAIL: empty or duplicate overlay property IDs in $set_file set" >&2
    exit 1
  fi
done
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/generated.txt"
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/executed.txt"
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/reported.txt"

jq -n \
  --slurpfile propertyReport "$PROPERTY_REPORT" \
  --rawfile declared "$WORK_DIR/declared.txt" \
  --rawfile generated "$WORK_DIR/generated.txt" \
  --rawfile executed "$WORK_DIR/executed.txt" \
  --rawfile reported "$WORK_DIR/reported.txt" \
  --arg baseRevision "$BASE_REVISION" \
  --arg hydratorDigest "$HYDRATOR_BUILD_DIGEST" \
  '{schema:"kernel.git-overlay-qualification-report.v0",baseRevision:{format:"sha1",hex:$baseRevision},hydratorDigest:$hydratorDigest,declaredPropertyIDs:($declared|split("\n")|map(select(length>0))),generatedPropertyIDs:($generated|split("\n")|map(select(length>0))),executedPropertyIDs:($executed|split("\n")|map(select(length>0))),reportedPropertyIDs:($reported|split("\n")|map(select(length>0))),propertyReport:$propertyReport[0]}' \
  >"$QUALIFICATION_REPORT"
(
  cd "$MODEL_ROOT"
  cue vet . "$QUALIFICATION_REPORT" -d '#GitOverlayQualificationReport'
)

printf '%s\n' "Overlay property report: $PROPERTY_REPORT"
printf '%s\n' "Overlay qualification report: $QUALIFICATION_REPORT"
printf '%s\n' "==> Git overlay qualification passed"
