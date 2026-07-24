#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

cue fmt --check --files \
  .codex/codex-profile/contracts/*.cue \
  .codex/codex-profile/contracts/fixtures/positive/*.cue \
  .codex/codex-profile/contracts/fixtures/negative/*/*.cue

cd "$REPO_ROOT/.codex/codex-profile/contracts"
cue vet .
cue vet -c .
cue vet ./fixtures/positive

negative_count=0
while IFS= read -r fixture_dir; do
  negative_count=$((negative_count + 1))
  if cue vet "./$fixture_dir" >/tmp/codex-profile-negative.out 2>/tmp/codex-profile-negative.err; then
    echo "FAIL: expected negative fixture failure, but validation succeeded: $fixture_dir"
    cat /tmp/codex-profile-negative.out
    exit 1
  fi
  echo "PASS: expected negative fixture failure observed: $fixture_dir"
done < <(find fixtures/negative -mindepth 1 -maxdepth 1 -type d -print | sort)

if (( negative_count == 0 )); then
  echo "FAIL: no negative codex-profile fixtures were discovered"
  exit 1
fi

cd "$REPO_ROOT"
uv run --project .codex/codex-profile -- python .codex/codex-profile/tests/test_replay.py -v
uv run --project .codex/codex-profile -- python .codex/codex-profile/tests/test_ingestion.py -v
uv run --project .codex/codex-profile -- python .codex/codex-profile/tests/test_verify_upstream.py -v
uv run --project .codex/codex-profile --group test -- pytest -q \
  .codex/codex-profile/tests/test_handoff.py \
  .codex/codex-profile/tests/test_runner.py \
  .codex/codex-profile/tests/test_property_gate.py \
  .codex/codex-profile/tests/test_cli.py
python -m unittest -v tools/test_codex_corpus_profile.py
uv run --project .codex/codex-profile -- python -m compileall -q .codex/codex-profile/src
uv run --project .codex/codex-profile -- python -m py_compile \
  .codex/codex-profile/scripts/verify_upstream.py \
  .codex/codex-profile/tests/test_replay.py \
  .codex/codex-profile/tests/test_ingestion.py \
  .codex/codex-profile/tests/test_verify_upstream.py \
  .codex/codex-profile/tests/test_handoff.py \
  .codex/codex-profile/tests/test_runner.py \
  .codex/codex-profile/tests/test_property_gate.py \
  .codex/codex-profile/tests/test_cli.py
