# Codex profile contracts

This subtree is the contract-first foundation for issue #72. It now contains the
read-only rollout collector and DuckDB ingestion path. Checkpoint writers,
hooks, wrappers, Marimo analysis, and policy runtime remain deferred.

The dependency order is:

```text
pinned upstream shapes and replay evidence
  -> CUE schemas
  -> named assertion catalog
  -> positive and negative CUE probes
  -> typed adapters and read-only collector runtime
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
uv run --project .codex/codex-profile -- python .codex/codex-profile/tests/test_ingestion.py -v
python .codex/codex-profile/scripts/verify_upstream.py --source-root /path/to/openai-codex-tag
```

Each immediate child of `contracts/fixtures/negative` must fail `cue vet`.

MVP CLI:

```bash
uv run --project .codex/codex-profile -- codex-profile ingest \
  --root ~/.local/share/codex \
  --repo /home/_404/src/dotfiles \
  --database ~/.local/state/codex-profile/profile.duckdb \
  --strict
uv run --project .codex/codex-profile -- codex-profile analyze \
  --database ~/.local/state/codex-profile/profile.duckdb
uv run --project .codex/codex-profile -- codex-profile export \
  --database ~/.local/state/codex-profile/profile.duckdb \
  --out /tmp/codex-profile
```
