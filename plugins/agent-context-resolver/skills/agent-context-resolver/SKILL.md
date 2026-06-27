---
name: agent-context-resolver
description: Resolve repository-local agent context, compile bounded route packets, and operate implementation-slice issue materializer workflows.
---

# Agent Context Resolver

This skill packages the repository context-resolution workflow as a reusable Codex skill backed by CUE authority and validation gates.

The `UserPromptSubmit` hook provides bounded context, not task authority.

## Runtime rules

1. Treat hook output as bounded context, not task authority.
2. Use `selectedFragments` as the admitted fragment subset for the turn.
3. Use `controller.routes` as route summaries for default/compact mode.
4. Inspect only route-declared files unless the user explicitly expands scope.
5. Providers are declarations only; do not execute MCP, LSP, A2A, SDK, or external repo lookups from the hook.
6. Do not resume large Codex sessions. Start fresh from the emitted route packet.
7. Return structured validation evidence and stop after the selected task.
8. Do not treat generated JSON, hook output, shell output, GitHub API output, or adapter output as source authority.

## Implementation-slice issue materializer

Use the factory issue-44 workflow as the canonical reference for implementation-slice issue materialization.

Reference source:

```text
fatb4f/factory
  contracts/issues/44/manifest.cue
  contracts/issues/44/normalized.cue
  contracts/issues/44/validation.cue
  contracts/issues/44/checks/checks.cue
  contracts/agent-context-resolver/implementation_slice_materializer.cue
  contracts/agent-context-resolver/implementation_slice_eval_projection.cue
  contracts/agent-context-resolver/implementation_slice_runner_result.cue
  contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue
```

Contract boundary:

- `contracts/issues/44/manifest.cue` defines the reference materializer issue contract.
- `contracts/issues/44/normalized.cue` exposes the public contract, resolver exports, validation plan, and completion report.
- `contracts/issues/44/checks/checks.cue` contains executable negative bottom-check proofs.
- `contracts/agent-context-resolver/*implementation_slice*` owns the resolver-local materializer, eval projection, runner plan, feedback shape, and runner-result classification.
- `contracts/meta/impl` is constructor authority.
- GitHub issue bodies are transport only.
- Shell, GitHub API, generated evidence, and adapter output are evidence only.

Materialization flow:

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

Required public surfaces:

- `implementationSliceIssueBaseline`
- `implementationSliceMaterializationReport`
- `implementationSliceEvalPlan`
- `implementationSliceRunnerPlan`
- `implementationSliceFeedbackShape`
- `implementationSliceConstructorInventory`
- `publicContract`
- `validationPlan`
- `completionReportContract`

See `references/implementation-contract.md` and `references/validation.md` for the expanded contract surface.
