# Implementation-slice issue materializer contract

Source authority lives in `fatb4f/factory`.

## Reference files

```text
contracts/issues/44/manifest.cue
contracts/issues/44/normalized.cue
contracts/issues/44/validation.cue
contracts/issues/44/checks/checks.cue
contracts/agent-context-resolver/implementation_slice_materializer.cue
contracts/agent-context-resolver/implementation_slice_eval_projection.cue
contracts/agent-context-resolver/implementation_slice_runner_result.cue
contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue
```

## Authority split

```text
contracts/meta/impl
  -> constructor authority

contracts/issues/44
  -> canonical implementation-slice materializer reference

contracts/agent-context-resolver
  -> resolver-local materializer, eval projection, runner plan, feedback shape, and result classification

GitHub issue body
  -> transport-only compact implementation slice

Shell, GitHub API, generated evidence, adapter output
  -> evidence only
```

## Materialization flow

1. Observe the raw implementation-slice issue body.
2. Parse it into `#ParsedImplementationSliceIssue`.
3. Load the issue-local CUE manifest and public exports.
4. Build an admissible `#IssueMaterializationCandidate`.
5. Derive eval obligations from the loaded issue.
6. Derive the eval plan from the obligations.
7. Derive the runner plan from the eval plan.
8. Classify runner results as evidence, including expected failures.
9. Evaluate issue-local negative fixtures through `_negativeBottomChecks`.
10. Produce the completion report sections declared by the issue manifest.

## Forbidden attractors

- route-only packets treated as full materialization candidates
- missing `contract.path` accepted as parsed issue contract
- static eval plans detached from loaded issue manifests
- missing negative check expressions accepted as proof
- any nonzero runner exit classified as pass
- generated artifacts or adapter outputs promoted to authority
- GitHub issue bodies promoted beyond transport evidence
