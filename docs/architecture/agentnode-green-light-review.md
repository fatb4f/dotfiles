# AgentNode Green-Light Review

Review date: 2026-06-03

## Decision

Decision: green-light.

Scope: green-lit for the thin AgentNode CUE-flow workflow demonstrated by the current adapter run: one root-declared `flow` task, normalized root response consumption, accepted context exposure, rejected diagnostics-only exposure, runtime trace emission, and rough context-size comparison.

This is not a green-light for semantic search, recursive traversal, planner behavior, daemon behavior, multi-node routing, or broader runtime policy. Go remains the adapter, emitter, and boundary enforcer; CUE remains the policy and projection source.

Accepted rough edges: the size estimator is rough, the live cases are fixture-backed, the task path is intentionally narrow, the gopls/MCP path is MVP, root-level `go test ./...` does not apply, prompt field duplication may still need normalization, and the adversarial fixture matrix is deferred.

## Implemented Proof Chain

| Link | Evidence |
|---|---|
| Fact-rooted relations | Relation edges cite known `factRefs`; fixtures export the CUE-flow relation slice. |
| Typed authorization evidence | Root-owned authorization evidence records selected patterns, loaded files, denied loads, relation refs, fact refs, and rationale. |
| Promotion by replayable CUE unification | Promotion status is derived by unifying gate, case, pattern fragment, invariants, evidence, allowed relations, and known facts. |
| Promoted projection binding | Accepted bindings expose selected files and projection context; drift bindings expose diagnostics. |
| Normalized root response | Root response has `consumable.accepted/status`; accepted responses require `agentContext`; non-accepted responses require `diagnostics` and reject `agentContext`. |
| Go CUE-flow adapter consumption | The adapter decodes `normalizedResponse` into `Consumable`, `AgentContext`, and `Diagnostics` fields instead of reading promotion internals for exposure decisions. |
| Runtime trace and rough estimate | The live adapter report includes accepted/rejected consumable state, exposed files, denied loads, relation refs, fact refs, broad input surface, and projected context surface. |

Relevant commits:

| Commit | Role |
|---|---|
| `375d196878864339a1f987af3e7da25e0658d32b` | Promoted projection binding and normalized root response. |
| `3bce35b2586d82d278d282a0b40cab39860a0dab` | Normalized CUE-flow adapter consumption, runtime trace surfaces, and rough context estimator. |

## Validation Evidence

Validation commands reported for the current slice:

| Command | Result |
|---|---|
| `cue vet .` | Passed. |
| `cue vet ./cue/agentnode/...` | Passed. |
| `cue vet ./nodes/workspace/...` | Passed. |
| `cue vet ./cue/patterns/...` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowFactRootedRelationSlice --out json` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowAuthorizationEvidenceSlice --out json` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowPromotionByUnificationSlice --out json` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowPromotedProjectionBindingSlice --out json` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowValidationAssessmentSlice --out json` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowValidationReportManifest --out json` | Passed. |
| `go test ./...` from `shell-wrap/src/hookrail` | Passed. |
| Repo-root `go test ./...` | Not applicable; the repository root is not a Go module root. |

Adapter command run for this review:

```sh
go run ./cmd/hookrail-flow --trace-out ../../../var/run/hookrail/flow-trace.latest.json
```

Working directory:

```text
shell-wrap/src/hookrail
```

Stable trace artifact:

```text
var/run/hookrail/flow-trace.latest.json
```

Stable validation report artifact:

```text
var/run/hookrail/validation-report.latest.json
```

Materialization command:

```sh
cue export ./cue/patterns/projections -e cueFlowValidationReportManifest --out json > var/run/hookrail/validation-report.latest.json
```

Adapter result: passed with `schemaVersion: "cuerail.hookrailFlowReport.v1"`, `taskKind: "gopls"`, evidence `status: "ok"`, and `diagnostics: "No diagnostics."`.

## Runtime Observation

The live adapter result executed the declared CUE-flow task path exactly as `flow`. The accepted response came from normalized root response data and exposed context; the rejected response exposed diagnostics only.

| Observation | Accepted | Rejected |
|---|---:|---:|
| `consumable.accepted` | `true` | `false` |
| `consumable.status` | `accepted` | `drift` |
| Exposed files | 3 | 0 |
| Denied loads | 0 | 2 |
| Broad input bytes | 87,137 | 87,137 |
| Broad input lines | 2,618 | 2,618 |
| Broad input files | 10 | 10 |
| Projected context bytes | 34,229 | 0 |
| Projected context lines | 1,026 | 0 |
| Projected context files | 3 | 0 |

Accepted context reduction from this run:

| Metric | Reduction |
|---|---:|
| Bytes | 60.7% |
| Lines | 60.8% |
| Files | 70.0% |

The estimator is a rough bytes, newline-counted lines, and file-count comparison over repo files. It is not tokenizer exact.

## Boundary Result

| Boundary | Result |
|---|---|
| Accepted response | Exposes `agentContext`, including selected patterns, exposed files, prompt projection, evidence summary, relation refs, and fact refs. |
| Non-accepted response | Exposes `diagnostics` only, including status, classification, violations, denied loads, relation refs, and fact refs. |
| Go consumption | Uses `consumable.accepted/status` and normalized response fields to decide exposure shape. |
| Promotion internals | Go does not consume promotion internals for exposure decisions. |
| Policy source | Go remains adapter/emitter/enforcer; it does not become the authorization policy source. |

## Rough Edges

| Edge | Accepted disposition |
|---|---|
| Byte/line/file estimate is not tokenizer exact. | Accept for green-light; improve only if later runs need tokenizer precision. |
| Current accepted/rejected cases are fixture-backed. | Accept for this decision because the adapter consumed the normalized runtime result and enforced the boundary in Go. |
| Task path is narrow and asserted as exactly `flow`. | Accept; this is the intended slice boundary. |
| gopls/MCP path is MVP. | Accept; it proves the adapter can run and emit root-shaped evidence. |
| Repo-root `go test ./...` is not applicable. | Accept; validation belongs to the Go module at `shell-wrap/src/hookrail`. |
| `projectedPrompt` and `promptProjection` duplication may need normalization later if still present. | Defer until it becomes a consumer problem. |
| Adversarial fixture matrix is deferred. | Defer until more observed traces define the negative-path matrix. |

## Next Hardening List

1. Persist trace artifacts per run if comparison history is needed beyond `flow-trace.latest.json`.
2. Add an exact tokenizer or better estimator if rough byte/line/file estimates stop being predictive.
3. Add more real task-pattern runs.
4. Harden the negative-path matrix from observed traces.
5. Normalize `projectedPrompt` versus `promptProjection` if the duplication remains after consumer integration.
6. Add a CI wrapper for the module-local Go test and the CUE exports.
