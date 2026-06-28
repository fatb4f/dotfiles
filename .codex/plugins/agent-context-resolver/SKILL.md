---
name: dotfiles-agent-context-resolver
description: Resolve bundled dotfiles repository context, compile bounded route packets, and operate implementation-slice issue materializer workflows.
---

# Dotfiles Agent Context Resolver

This plugin is self-contained at runtime. It uses bundled JSON projections plus `sh` and `jq`.

The `UserPromptSubmit` hook provides bounded context, not task authority.

## Runtime rules

1. Treat hook output as bounded context, not task authority.
2. Use `selectedFragments` as the admitted fragment subset for the turn.
3. Use `controller.routes` as route summaries for default/compact mode.
4. Inspect only route-declared files unless the user explicitly expands scope.
5. Providers in `provider_inventory.json` are declarations only; do not execute MCP, LSP, A2A, SDK, or external repo lookups from the hook.
6. Do not resume large Codex sessions. Start fresh from the emitted route packet.
7. Return structured validation evidence and stop after the selected task.
8. Do not treat generated JSON, hook output, shell output, GitHub API output, or adapter output as source authority.

## Output modes

Default output is compact and quota-bounded. It includes selected fragments, provider IDs/summaries, route summaries, deny rules, and budget.

Full debug output is available only when explicitly requested:

```sh
AGENT_CONTEXT_VERBOSE=1 \
  sh .codex/plugins/agent-context-resolver/scripts/resolve-agent-context \
  --prompt "dotfiles wezterm xplr workspace ide"
```

## CLI

```sh
sh .codex/plugins/agent-context-resolver/scripts/resolve-agent-context \
  --prompt "dotfiles wezterm xplr workspace ide"
```

## Runtime dependencies

- `sh`
- `jq`
- bundled files under `.codex/plugins/agent-context-resolver/generated/`

## Implementation-slice issue materializer

Use the factory issue-44 workflow as the canonical reference for implementation-slice issue materialization.

Reference source:

```text
fatb4f/factory
  contracts/issues/44/manifest.cue
  contracts/issues/44/normalized.cue
  contracts/issues/44/validation.cue
  contracts/issues/44/checks/checks.cue
  contracts/plugin-bundle/agent-context-resolver/src/implementation_slice_materializer.cue
  contracts/plugin-bundle/agent-context-resolver/src/implementation_slice_eval_projection.cue
  contracts/plugin-bundle/agent-context-resolver/src/implementation_slice_runner_result.cue
  contracts/plugin-bundle/agent-context-resolver/src/implementation_slice_constructor_inventory.cue
```

Bundled materialized source:

```text
.codex/plugins/agent-context-resolver/contracts/agent-context-resolver
.codex/plugins/agent-context-resolver/contracts/meta/impl
.codex/plugins/agent-context-resolver/cue.mod/module.cue
```

Contract boundary:

- `contracts/issues/44/manifest.cue` defines the reference materializer issue contract.
- `contracts/issues/44/normalized.cue` exposes the public contract, resolver exports, validation plan, and completion report.
- `contracts/issues/44/checks/checks.cue` contains executable negative bottom-check proofs.
- The bundled `.codex/plugins/agent-context-resolver/contracts/agent-context-resolver/*implementation_slice*` files carry the resolver-local materializer, eval projection, runner plan, feedback shape, and runner-result classification.
- The bundled `.codex/plugins/agent-context-resolver/contracts/meta/impl` tree carries constructor authority required by the materialized plugin.
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
cd .codex/plugins/agent-context-resolver
cue vet ./contracts/agent-context-resolver
cue export ./contracts/agent-context-resolver -e implementationSliceIssueBaseline
cue export ./contracts/agent-context-resolver -e implementationSliceMaterializationReport
cue export ./contracts/agent-context-resolver -e implementationSliceEvalPlan
cue export ./contracts/agent-context-resolver -e implementationSliceRunnerPlan
cue vet ./contracts/meta/impl
cue export ./contracts/meta/impl -e constructorLibraryBaseline
! cue export ./contracts/agent-context-resolver/checks -e '_negativeBottomChecks.routeOnlyPacket'
! cue export ./contracts/agent-context-resolver/checks -e '_negativeBottomChecks.missingContractPath'
! cue export ./contracts/agent-context-resolver/checks -e '_negativeBottomChecks.staticEvalPlan'
! cue export ./contracts/agent-context-resolver/checks -e '_negativeBottomChecks.missingNegativeCheckExpression'
! cue export ./contracts/agent-context-resolver/checks -e '_negativeBottomChecks.anyNonzeroAsPass'
```

Forbidden attractors:

- external factory root lookup at runtime
- external contract.cuemod root lookup at runtime
- route-only packets treated as full materialization candidates
- missing `contract.path` accepted as parsed issue contract
- static eval plans detached from loaded issue manifests
- missing negative check expressions accepted as proof
- any nonzero runner exit classified as pass
- generated artifacts or adapter outputs promoted to authority
- GitHub issue bodies promoted beyond transport evidence
