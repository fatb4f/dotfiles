# AgentNode Green-Light Review

Decision: green-lit for continued thin live workflow use, with the rough edges below kept out of the next hardening set until trace data says otherwise.

Review date: 2026-06-02

## Relevant Commits

| Commit | Role |
|---|---|
| `d0c93cadcdeadee5a2472cf87d4be90e93db003b` | Fact-rooted CUE flow relation slice. |
| `ffa48614780c83691b59095a5078603be4a9922f` | Typed authorization evidence slice. |
| `d0ef8733d69c26ec6b77ae8072cc58d7abc1e810` | Promotion by replayable CUE unification slice. |
| Close-out commit for this review | Promoted projection binding, normalized root response, runtime trace, and green-light review. |

## Validation Commands

| Command | Result |
|---|---|
| `cue vet .` | Passed with no output. |
| `cue vet ./cue/agentnode/...` | Passed with no output. |
| `cue vet ./nodes/workspace/...` | Passed with no output. |
| `cue vet ./cue/patterns/...` | Passed with no output. |
| `cue export ./cue/patterns/projections -e cueFlowFactRootedRelationSlice --out json` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowAuthorizationEvidenceSlice --out json` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowPromotionByUnificationSlice --out json` | Passed. |
| `cue export ./cue/patterns/projections -e cueFlowPromotedProjectionBindingSlice --out json` | Passed. |
| `go test ./...` from `shell-wrap/src/hookrail` | Passed. |

## Adapter Run

Command:

```sh
go run ./cmd/hookrail-flow --trace-out /tmp/hookrail-flow-trace.json
```

Working directory:

```text
shell-wrap/src/hookrail
```

Trace artifact:

```text
/tmp/hookrail-flow-trace.json
```

## Observed Runtime Evidence

The live run executed one root-declared CUE flow task, `kind: "gopls"`, rooted at `flow`. Go loaded the CUE flow app and the promoted projection binding, supplied the minimal `gopls` runner, and filled root-shaped evidence.

The accepted response came from `cueFlowPromotedProjectionBindingSlice.fixtures.good.normalizedResponse`. It exposed:

| Field | Observed value |
|---|---|
| `accepted` | `true` |
| `selectedPatternIDs` | `cue-flow-fact-rooted-relation`, `selected-pattern-contract` |
| exposed files | 3 |
| admitted relation | `rel.selected-pattern-authorizes-loaded-file` |

The rejected response came from `cueFlowPromotedProjectionBindingSlice.fixtures.bad.keywordRelevance.normalizedResponse`. It exposed:

| Field | Observed value |
|---|---|
| `accepted` | `false` |
| status | `drift` |
| exposed files | 0 |
| denied loads | 2 |
| classification | `architectural-drift` |

## Token Bleed Estimate

Estimator: rough bytes, newline-counted lines, and file count from repo files. This is not tokenizer-exact.

| Surface | Bytes | Lines | Files |
|---|---:|---:|---:|
| Broad input surface | 81,066 | 2,458 | 10 |
| Accepted projected context | 32,405 | 964 | 3 |
| Rejected projected context | 0 | 0 | 0 |

Observed accepted reduction:

| Metric | Reduction |
|---|---:|
| Bytes | 60.0% |
| Lines | 60.8% |
| Files | 70.0% |

## Boundary Check

The schema proof and the runtime evidence remain separate:

| Boundary | Observed behavior |
|---|---|
| Projection authority | CUE owns `#PromotedProjection`, `#NormalizedRootResponse`, and `cueFlowPromotedProjectionBindingSlice`. |
| Adapter role | Go loads CUE, supplies one `gopls` runner, and computes rough size evidence. |
| Accepted exposure | Selected pattern IDs, exposed files, prompt, and context projection appear only under an accepted promotion outcome. |
| Rejected exposure | Rejected/drift response contains diagnostics, violations, rationale, denied loads, relation refs, and fact refs only. |
| Hidden policy | No Go-only authorization or broad task inference was introduced. |

## Rough Edges

| Edge | Disposition |
|---|---|
| Size estimate is byte/line/file based, not tokenizer exact. | Accept for green-light; replace only if later trace comparisons need tokenizer precision. |
| Broad input surface is a declared comparison set, not a dynamic full-repo scan. | Accept; this preserves the no-broad-discovery boundary. |
| Runtime trace currently records one accepted fixture and one rejected fixture. | Accept; defer full negative-path matrix until after more live data. |
| The trace artifact path is caller-selected and outside repo authority by default. | Accept; keep generated runtime evidence out of committed CUE authority. |

## Next Hardening Set

1. Add one more live trace only after a second declared task path exists.
2. Promote the rough estimator to tokenizer-aware only if byte/line estimates stop predicting context bleed.
3. Expand negative fixtures after a live run shows an actual leak or ambiguous diagnostic.
4. Add stable trace artifact naming if multiple adapter runs need comparison.
5. Keep multi-pattern routing and planner behavior deferred.
