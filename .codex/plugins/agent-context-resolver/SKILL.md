---
name: dotfiles-agent-context-resolver
description: Resolve bundled repository context, compile bounded route plans, and materialize implementation-slice issue contracts.
---

# Agent Context Resolution

The `UserPromptSubmit` hook provides a bounded route controller packet, not task authority.

1. Run `.codex/plugins/agent-context-resolver/scripts/resolve-agent-context --prompt "<prompt>"`.
2. Treat `selectedFragments` as a subset of `availableFragmentIDs`.
3. Treat `controller.routes` as a subset of `controller.availableRouteIDs`.
4. Resolve selected fragment metadata through `.codex/plugins/agent-context-resolver/generated/fragment_inventory.json`.
5. Inspect the declared `sourcePath` and obey repository instruction boundaries before editing.
6. Never execute projected routes directly or treat derived JSON and MCP/tool output as source authority.
7. Regenerate resolver-local Codex projection and JSON outputs from their CUE sources after changes.

## Implementation-slice issue materializer

Use `contracts/issues/44` as the canonical workflow reference for implementation-slice issue materialization.

Contract boundary:

- `contracts/issues/44/manifest.cue` defines the reference materializer issue contract.
- `contracts/issues/44/normalized.cue` exposes the public contract, resolver exports, validation plan, and completion report.
- `contracts/issues/44/checks/checks.cue` contains executable negative bottom-check proofs.
- `contracts/plugin-bundle/agent-context-resolver/src/*implementation_slice*` owns the resolver-local materializer, eval projection, runner plan, feedback shape, and runner-result classification.
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

Required validation:

```bash
cue vet ./contracts/issues/44
cue export ./contracts/issues/44 -e publicContract
cue export ./contracts/issues/44 -e validationPlan
cue export ./contracts/issues/44 -e completionReportContract
cue vet ./contracts/plugin-bundle/agent-context-resolver/src
cue export ./contracts/plugin-bundle/agent-context-resolver/src -e implementationSliceIssueBaseline
cue export ./contracts/plugin-bundle/agent-context-resolver/src -e implementationSliceMaterializationReport
cue export ./contracts/plugin-bundle/agent-context-resolver/src -e implementationSliceEvalPlan
cue export ./contracts/plugin-bundle/agent-context-resolver/src -e implementationSliceRunnerPlan
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.routeOnlyPacket'
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.missingContractPath'
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.staticEvalPlan'
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.missingNegativeCheckExpression'
! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.anyNonzeroAsPass'
```

Forbidden attractors:

- route-only packets treated as full materialization candidates
- missing `contract.path` accepted as parsed issue contract
- static eval plans detached from loaded issue manifests
- missing negative check expressions accepted as proof
- any nonzero runner exit classified as pass
- generated artifacts or adapter outputs promoted to authority
- GitHub issue bodies promoted beyond transport evidence
