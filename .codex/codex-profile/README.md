# Codex profile contracts

This subtree is the contract-first foundation for issue #72. It intentionally
contains no collector, checkpoint writer, hook, DuckDB, or policy runtime yet.

The dependency order is:

```text
pinned upstream shapes and replay evidence
  -> CUE schemas
  -> named assertion catalog
  -> positive and negative CUE probes
  -> typed adapters and runtime work in later slices
```

Validate the current slice with:

```bash
cue fmt --check --files .codex/codex-profile/contracts/*.cue \
  .codex/codex-profile/contracts/fixtures/*/*.cue \
  .codex/codex-profile/contracts/fixtures/negative/*/*.cue
cue vet ./.codex/codex-profile/contracts
cue vet -c ./.codex/codex-profile/contracts
(cd .codex/codex-profile/contracts && cue vet ./fixtures/positive)
python .codex/codex-profile/tests/test_replay.py -v
python .codex/codex-profile/scripts/verify_upstream.py --source-root /path/to/openai-codex-tag
```

Each immediate child of `contracts/fixtures/negative` must fail `cue vet`.
