#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cd "$REPO_ROOT/.github"

echo "==> Running static validation checks"
cue vet ./contracts

echo "==> Extracting CUE validation matrix"
cases_json="$(cue export ./contracts -e _validationCases --out json)"

echo "$cases_json" | jq -c '.[]' | while read -r case; do
  id="$(jq -r '.id' <<<"$case")"
  kind="$(jq -r '.command.kind' <<<"$case")"
  expected_failure="$(jq -r '.command.expectedFailure' <<<"$case")"
  mapfile -t argv < <(jq -r '.command.argv[]' <<<"$case")
  stdout="$tmpdir/$id.out"
  stderr="$tmpdir/$id.err"
  printf 'Processing: case=%s kind=%s\n' "$id" "$kind"
  if [[ "$kind" == "cue-export-expected-failure" && "$expected_failure" == "true" ]]; then
    if "${argv[@]}" >"$stdout" 2>"$stderr"; then
      echo "FAIL: expected failure, but command succeeded: $id"
      cat "$stdout"
      exit 1
    fi
    echo "PASS: expected failure observed: $id"
    continue
  fi
  if [[ ( "$kind" == "cue-export-expected-success" || "$kind" == "cue-export-package-expected-success" ) && "$expected_failure" == "false" ]]; then
    if ! "${argv[@]}" >"$stdout" 2>"$stderr"; then
      echo "FAIL: expected success, but command failed: $id"
      cat "$stderr"
      exit 1
    fi
    echo "PASS: expected success observed: $id"
    continue
  fi
  echo "FAIL: unsupported validation command signature: $kind"
  exit 1
done

echo "==> Running LazyVim project delta regression matrix"
bash ./contracts/test_lazyvim_project_delta.sh

echo "==> Validating nested context-model module"
cd "$REPO_ROOT/.codex/context-model"
cue vet .
cue export . -e rootSeed --out json >"$tmpdir/context-model-root-seed.json"
cue export . -e workbookConfig --out json >"$tmpdir/context-model-workbook-config.json"
cue vet ./fixtures/positive
cue export ./fixtures/positive -e minimal --out json >"$tmpdir/context-model-positive.json"
bash "$REPO_ROOT/.github/scripts/context-selection-property-test.sh"

negative_count=0
while IFS= read -r fixture_dir; do
  negative_count=$((negative_count + 1))
  fixture_id="${fixture_dir##*/}"
  stdout="$tmpdir/context-model-$fixture_id.out"
  stderr="$tmpdir/context-model-$fixture_id.err"
  if cue vet "./$fixture_dir" >"$stdout" 2>"$stderr"; then
    echo "FAIL: expected context-model fixture failure, but validation succeeded: $fixture_id"
    cat "$stdout"
    exit 1
  fi
  echo "PASS: expected context-model fixture failure observed: $fixture_id"
done < <(find fixtures/negative -mindepth 1 -maxdepth 1 -type d -print | sort)

if (( negative_count == 0 )); then
  echo "FAIL: no negative context-model fixtures were discovered"
  exit 1
fi

echo "==> All CUE contract validation cases passed"
