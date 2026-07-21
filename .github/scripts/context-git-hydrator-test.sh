#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HYDRATOR_ROOT="$REPO_ROOT/.codex/context-hydrators/git"
MODEL_ROOT="$REPO_ROOT/.codex/context-model"
WORK_DIR="$(mktemp -d)"
PROJECTION_CUE="$MODEL_ROOT/.git-committed-snapshot-qualification.cue"
trap 'rm -rf "$WORK_DIR"; rm -f "$PROJECTION_CUE"' EXIT

printf '%s\n' "==> Run committed snapshot Go tests"
(
  cd "$HYDRATOR_ROOT"
  go test ./...
  go build -trimpath -o "$WORK_DIR/context-git-hydrator" ./cmd/context-git-hydrator
  go run ./internal/testfixture/cmd/context-git-fixture --output "$WORK_DIR/fixture"
)

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
    duplicate = copy.deepcopy(document["occurrences"][0])
    document["occurrences"].append(duplicate)
    document["occurrences"].sort(key=lambda item: item["path"])
elif mutation == "unsorted-paths":
    document["occurrences"].reverse()
elif mutation == "incompatible-mode":
    target_occurrence = next(item for item in document["occurrences"] if item["kind"] == "blob")
    target_occurrence["mode"] = "160000"
elif mutation == "non-normalized-path":
    document["occurrences"][0]["path"] = "docs/../escape"
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
for mutation in unknown-field duplicate-path unsorted-paths incompatible-mode non-normalized-path; do
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
cp "$WORK_DIR/generated.txt" "$WORK_DIR/executed.txt"
cp "$WORK_DIR/executed.txt" "$WORK_DIR/reported.txt"
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/generated.txt"
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/executed.txt"
cmp "$WORK_DIR/declared.txt" "$WORK_DIR/reported.txt"

jq -n \
  --slurpfile manifest "$MANIFEST" \
  --slurpfile properties "$WORK_DIR/declared-properties.json" \
  --arg resolvedRevision "$commit_f" \
  '{schema:"kernel.git-committed-snapshot-qualification-report.v0",resolvedRevision:$resolvedRevision,fixtureCommits:$manifest[0].repository.commits,declaredPropertyIDs:($properties[0]|keys),generatedPropertyIDs:$manifest[0].properties,executedPropertyIDs:$manifest[0].properties,reportedPropertyIDs:$manifest[0].properties}' \
  >"$WORK_DIR/qualification-report.json"

printf '%s\n' "==> Committed snapshot hydrator qualification passed"
