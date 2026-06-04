# Agentflow Pre-Mutation Gate

Status: mutation wrapper proof slice.

## Invariant

No mutating workflow may perform the first file mutation until a run manifest unifies with `agentflow.#AcceptedAgentFlowRun`.

The accepted manifest must represent:

- root MCP consultation
- root-private downstream workflow resolution
- execution DAG projection
- mutating node inventory
- projection-derived mutation scope
- CUE-vetted promo gate evidence
- ordering evidence that projection and acceptance happened before mutation

Presence is not enough. A scoped node has to prove `projectedBeforeMutation: true`, `mutationScopeDerived: true`, and `mutationObservedAfterProjection: true`.

## Proof Command

```sh
bin/agentflow-check cue/contracts/agentflow/runs/good-premutation.cue
```

Controlled mutation path:

```sh
bin/agentflow-mutate \
  --manifest cue/contracts/agentflow/runs/good-premutation.cue \
  -- touch tmp/agentflow-proof-ok
```

Expected rejection families:

```sh
! bin/agentflow-check cue/contracts/agentflow/runs/bad-missing-promo.cue
! bin/agentflow-check cue/contracts/agentflow/runs/bad-scope-drift.cue
! bin/agentflow-mutate \
  --manifest cue/contracts/agentflow/runs/bad-missing-promo.cue \
  -- touch tmp/agentflow-proof-bad
! bin/agentflow-mutate \
  --manifest cue/contracts/agentflow/runs/bad-scope-drift.cue \
  -- touch tmp/agentflow-proof-drift
! bin/agentflow-mutate \
  -- touch tmp/agentflow-proof-missing
```

## Boundary

The genesis contract commit created the validator language. The first repair commit added the executable pre-mutation check surface. This slice adds a controlled write-capable command boundary that invokes the check before the requested command runs.

This proves first-pass gate coverage for commands routed through `bin/agentflow-mutate`. It does not prove full runtime coverage for every other possible write path.
