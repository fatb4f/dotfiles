#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

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

  if [[ "$kind" == "cue-export-expected-success" && "$expected_failure" == "false" ]]; then
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

echo "==> All CUE contract validation cases passed"
