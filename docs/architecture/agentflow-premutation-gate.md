# Agentflow Pre-Mutation Gate

Status: contract gate proof slice.

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

Expected rejection families:

```sh
! bin/agentflow-check cue/contracts/agentflow/runs/bad-missing-promo.cue
! bin/agentflow-check cue/contracts/agentflow/runs/bad-scope-drift.cue
```

## Boundary

The genesis contract commit created the validator language. This slice adds the executable pre-mutation check surface for future mutating work.

It still depends on the agent or wrapper invoking `bin/agentflow-check` before mutation. The next enforcement step is to bind that command into the mutating runtime wrapper.
