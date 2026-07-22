#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HYDRATOR_ROOT="$REPO_ROOT/.codex/context-hydrators/git"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
WORK_DIR="$(mktemp -d)"
QUALIFICATION_DIR="${CONTEXT_GIT_QUALIFICATION_DIR:-${TMPDIR:-/tmp}/context-git-hydrator-qualification}"
PROJECTION_CUE="$MODEL_ROOT/git_committed_snapshot_qualification.cue"
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

printf '%s\n' "==> Run committed snapshot Go tests"
(
  cd "$HYDRATOR_ROOT"
  go mod download
  go mod verify
  CONTEXT_GIT_HYDRATOR_PROPERTY_REPORT="$PROPERTY_REPORT" \
    go test -count=1 -json ./... | tee "$GO_TEST_LOG"
  git diff --exit-code -- go.mod go.sum
  go build -trimpath -ldflags "$HYDRATOR_LDFLAGS" -o "$WORK_DIR/context-git-hydrator" ./cmd/context-git-hydrator
  go run ./internal/testfixture/cmd/context-git-fixture --output "$WORK_DIR/fixture"
)

test -s "$PROPERTY_REPORT"
MANIFEST="$WORK_DIR/fixture/manifest.json"
OBSERVATIONS="$WORK_DIR/observations"
PROJECTIONS="$WORK_DIR/projections"
REQUESTS="$WORK_DIR/requests"
mkdir -p "$OBSERVATIONS" "$PROJECTIONS" "$REQUESTS"

printf '%s\n' "==> Execute hydrator and CUE projection for fixture commits A-F"
for fixture_id in A B C D E F; do
  commit="$(jq -er --arg id "$fixture_id" '.repository.commits[$id]' "$MANIFEST")"
  request="$REQUESTS/$fixture_id.json"
  observation="$OBSERVATIONS/$fixture_id.json"
  projection="$PROJECTIONS/$fixture_id.json"

  jq -n \
    --arg repositoryID "repo.fixture" \
    --arg revision "$commit" \
    '{schema:"kernel.git-committed-snapshot-request.v0",repositoryID:$repositoryID,path:"repository",revision:$revision}' \
    >"$request"

  (
    cd "$WORK_DIR/fixture"
    "$WORK_DIR/context-git-hydrator" committed --request "$request" >"$observation"
  )

  jq -e --arg digest "$HYDRATOR_BUILD_DIGEST" '.hydrator.digest == $digest' "$observation" >/dev/null
  jq -e '.requestedRevision == .resolvedRevision.hex' "$observation" >/dev/null

  (
    cd "$MODEL_ROOT"
    cue vet . "$observation" -d '#GitCommittedSnapshotObservation'
  )

  {
    printf '%s\n' 'package contextmodel'
    printf '%s\n' 'qualificationProjection: #GitCommittedSnapshotProjection & {'
    printf '%s\n' '  observation:'
    sed 's/^/  /' "$observation"
    printf '%s\n' '  schemaDigest: "sha256:1111111111111111111111111111111111111111111111111111111111111111"'
    printf '%s\n' '  policyDigest: "sha256:2222222222222222222222222222222222222222222222222222222222222222"'
    printf '%s\n' '}'
  } >"$PROJECTION_CUE"

  (
    cd "$MODEL_ROOT"
    cue export . -e qualificationProjection --out json >"$projection"
    cue vet . "$projection" -d '#GitCommittedSnapshotProjection'
  )
  rm -f "$PROJECTION_CUE"
done

printf '%s\n' "==> Verify byte-identical normalized output"
commit_f="$(jq -er '.repository.commits.F' "$MANIFEST")"
request_f="$REQUESTS/F.json"
for environment_id in default alternate; do
  output="$WORK_DIR/F-$environment_id.json"
  if [[ "$environment_id" == alternate ]]; then
    (
      cd "$WORK_DIR/fixture"
      TZ=Pacific/Kiritimati LC_ALL=C LANG=C \
        "$WORK_DIR/context-git-hydrator" committed --request "$request_f" >"$output"
    )
  else
    (
      cd "$WORK_DIR/fixture"
      "$WORK_DIR/context-git-hydrator" committed --request "$request_f" >"$output"
    )
  fi
done
cmp "$WORK_DIR/F-default.json" "$WORK_DIR/F-alternate.json"
cmp "$WORK_DIR/F-default.json" "$OBSERVATIONS/F.json"
if grep -F "$WORK_DIR/fixture/repository" "$OBSERVATIONS/F.json"; then
  echo "FAIL: observation leaked the host fixture path" >&2
  exit 1
fi

printf '%s\n' "==> Verify equivalent revision selectors"
for selector in HEAD main refs/heads/main fixture-f refs/tags/fixture-f "$commit_f"; do
  selector_id="$(printf '%s' "$selector" | tr '/:' '__')"
  request="$REQUESTS/selector-$selector_id.json"
  output="$WORK_DIR/selector-$selector_id.json"
  jq -n \
    --arg repositoryID "repo.fixture" \
    --arg revision "$selector" \
    '{schema:"kernel.git-committed-snapshot-request.v0",repositoryID:$repositoryID,path:"repository",revision:$revision}' \
    >"$request"
  (
    cd "$WORK_DIR/fixture"
    "$WORK_DIR/context-git-hydrator" committed --request "$request" >"$output"
  )
  cmp "$OBSERVATIONS/F.json" "$output"
done

mutate_json() {
  local source="$1"
  local target="$2"
  local mutation="$3"
  python - "$source" "$target" "$mutation" <<'PY'
import copy
import json
import sys
source, target, mutation = sys.argv[1:]
with open(source, encoding="utf-8") as handle:
    document = json.load(handle)
if mutation == "unknown-field":
    document["unknown"] = True
elif mutation == "duplicate-path":
    document["occurrences"].append(copy.deepcopy(document["occurrences"][0]))
    document["occurrences"].sort(key=lambda item: item["path"])
elif mutation == "unsorted-paths":
    document["occurrences"].reverse()
elif mutation == "incompatible-mode":
    next(item for item in document["occurrences"] if item["kind"] == "blob")["mode"] = "160000"
elif mutation == "non-normalized-path":
    document["occurrences"][0]["path"] = "docs/../escape"
elif mutation == "noncanonical-revision":
    document["requestedRevision"] = "main"
elif mutation == "malformed-object-id":
    document["occurrences"][0]["objectID"]["hex"] = "not-hex"
elif mutation == "malformed-digest":
    document["hydrator"]["digest"] = "sha256:short"
elif mutation == "opaque-symlink-descendant":
    document["occurrences"] = [
        {"path":"link","mode":"120000","kind":"symlink","objectID":{"format":"sha1","hex":"d"*40},"size":4},
        {"path":"link/child","mode":"100644","kind":"blob","objectID":{"format":"sha1","hex":"e"*40},"size":1},
    ]
elif mutation == "opaque-submodule-descendant":
    document["occurrences"] = [
        {"path":"vendor","mode":"160000","kind":"submodule","objectID":{"format":"sha1","hex":"d"*40}},
        {"path":"vendor/child","mode":"100644","kind":"blob","objectID":{"format":"sha1","hex":"e"*40},"size":1},
    ]
elif mutation == "elevated-authority":
    document["collected"]["state"]["effectiveAuthority"] = "controller"
else:
    raise SystemExit(f"unknown mutation: {mutation}")
with open(target, "w", encoding="utf-8") as handle:
    json.dump(document, handle, separators=(",", ":"), sort_keys=False)
    handle.write("\n")
PY
}

expect_cue_reject() {
  local definition="$1"
  local document="$2"
  if (
    cd "$MODEL_ROOT"
    cue vet . "$document" -d "$definition" >/dev/null 2>&1
  ); then
    echo "FAIL: CUE accepted negative fixture $document as $definition" >&2
    exit 1
  fi
}

printf '%s\n' "==> Execute structural safety rejection matrix"
for mutation in unknown-field duplicate-path unsorted-paths incompatible-mode non-normalized-path noncanonical-revision malformed-object-id malformed-digest opaque-symlink-descendant opaque-submodule-descendant; do
  negative="$WORK_DIR/negative-observation-$mutation.json"
  mutate_json "$OBSERVATIONS/F.json" "$negative" "$mutation"
  expect_cue_reject '#GitCommittedSnapshotObservation' "$negative"
done
negative_projection="$WORK_DIR/negative-projection-elevated-authority.json"
mutate_json "$PROJECTIONS/F.json" "$negative_projection" elevated-authority
expect_cue_reject '#GitCommittedSnapshotProjection' "$negative_projection"

printf '%s\n' "==> Verify declared/generated/executed/reported equality"
(
  cd "$MODEL_ROOT"
  cue export . -e gitCommittedSnapshotProperties --out json >"$WORK_DIR/declared-properties.json"
)
jq -r 'keys[]' "$WORK_DIR/declared-properties.json" | sort >"$WORK_DIR/declared.txt"
jq -r '.properties[]' "$MANIFEST" | sort >"$WORK_DIR/generated.txt"
jq -r \
  'select(.Action == "pass" and ((.Test // "") | startswith("TestDeclaredGeneratedExecutedReportedPropertySetEquality/execute/"))) | .Test | split("/execute/")[1]' \
  "$GO_TEST_LOG" | sort >"$WORK_DIR/executed.txt"
jq -e 'all(.results[]; .status == "passed")' "$PROPERTY_REPORT" >/dev/null
jq -r '.results[].propertyID' "$PROPERTY_REPORT" | sort >"$WORK_DIR/reported.txt"
for set_file in declared generated executed reported; do
  if [[ -s "$WORK_DIR/$set_file.txt" ]] && [[ -n "$(uniq -d "$WORK_DIR/$set_file.txt")" ]]; then
    echo "FAIL: duplicate property IDs in $set_file set" >&2
    exit 1
  fi
done
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/generated.txt"
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/executed.txt"
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/reported.txt"

jq -n \
  --slurpfile manifest "$MANIFEST" \
  --slurpfile propertyReport "$PROPERTY_REPORT" \
  --rawfile declared "$WORK_DIR/declared.txt" \
  --rawfile generated "$WORK_DIR/generated.txt" \
  --rawfile executed "$WORK_DIR/executed.txt" \
  --rawfile reported "$WORK_DIR/reported.txt" \
  --arg resolvedRevision "$commit_f" \
  --arg hydratorDigest "$HYDRATOR_BUILD_DIGEST" \
  '{schema:"kernel.git-committed-snapshot-qualification-report.v1",resolvedRevision:$resolvedRevision,hydratorDigest:$hydratorDigest,fixtureCommits:$manifest[0].repository.commits,declaredPropertyIDs:($declared|split("\n")|map(select(length>0))),generatedPropertyIDs:($generated|split("\n")|map(select(length>0))),executedPropertyIDs:($executed|split("\n")|map(select(length>0))),reportedPropertyIDs:($reported|split("\n")|map(select(length>0))),propertyReport:$propertyReport[0]}' \
  >"$QUALIFICATION_REPORT"
(
  cd "$MODEL_ROOT"
  cue vet . "$QUALIFICATION_REPORT" -d '#GitCommittedSnapshotQualificationReport'
)

printf '%s\n' "Property report: $PROPERTY_REPORT"
printf '%s\n' "Qualification report: $QUALIFICATION_REPORT"
printf '%s\n' "==> Committed snapshot hydrator qualification passed"
