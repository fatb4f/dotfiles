# AgentNode Freeze Review

Freeze point: `8dc0eacaeaaf883c7ae8b853ff8f62980b17d094`

Scope: AGENTS.cue routing proof of concept only. This review does not propose semantic search, recursive routing, MCP expansion, daemon behavior, new workflow planning, or broad refactors.

## Implemented Contract Inventory

| Contract | Surface | Observed implementation |
|---|---|---|
| Root index | `AGENTS.cue` exports `rootAgentContract` | Declares root id/path, one indexed workspace contract, and bounded AgentNode operations: `searchKeywords`, `selectPatterns`, `readSelectedPatterns`, `projectWorkflow`. |
| AgentNode schema | `cue/agentnode/schema.cue` | Defines node metadata, keyword mapping, task pattern refs, root index, root selection response, and projected prompt shape. |
| Workspace node metadata | `nodes/workspace/AGENTS.cue` | Declares workspace keywords, aliases, negative discovery signals, two task pattern refs, forbidden loads, validation requirements, fixture/projection requirements, and closeout evidence expectations. |
| Workspace pattern cards | `nodes/workspace/patterns/*.cue` | Declares `wezterm.workspace` and `nvim.smart-splits` ids with single-pattern loadable files and workflow stages. |
| Domain pattern schema | `cue/patterns/domain/schema.cue` | Defines domain surfaces, scopes, discovery metadata, known good/failure records, invariants, gate requirements, and proof commands/artifacts. |
| Domain cards | `cue/patterns/domain/*.cue` | Declares descriptive domain cards for chezmoi, CUE, git, shell-wrap, and source-code boundaries. |
| Codex projection | `cue/patterns/projections/codex-slice.cue` | Projects selected domain/workflow cards into Codex-facing slices with known good/failure/invariant/gate proof data. |
| Root selection response | `nodes/workspace/projections.cue` exports `rootSelectionResponse` | Exports selected pattern ids, matched terms, rationale, loadable files, required validations/projections/skills, forbidden loads, and root-mediated evidence. |
| Bounded fixture | `nodes/workspace/projections.cue` exports `boundedDiscoveryFixture` | Reuses `rootSelectionResponse`, pins root-mediated mode, index sources, and forbidden loads. |
| Projected prompt | `nodes/workspace/projections.cue` exports `projectedPrompt.text` | Instructs agents to treat AGENTS.cue/root selections as authority, avoid broad inspection before selection, use bounded fallback, and record selection evidence. |

## Intended Boundaries

| Boundary | Should own | Should not own |
|---|---|---|
| CUE boundary | Schema, validation, typed contracts, declared discovery metadata, declared authority, projection inputs. | Runtime behavior, filesystem execution, MCP transport, dynamic enforcement. |
| Root authority boundary | Task-pattern brokering and only bounded selected context. | Generic filesystem search or implicit neighboring-file authorization. |
| Node metadata boundary | Relevance, ownership, support files, forbidden loads, and workflow requirements. | Independent authorization for arbitrary loading outside root selection. |
| Policy boundary | Root-owned, typed, auditable, testable policy fields. | Scattered prose prompts, comments, or implicit adapter behavior. |
| Agent prompt boundary | Root-selected patterns and bounded fallback instructions. | Normalized broad repo discovery or recursive AGENTS.md traversal. |

## Observed Drift

| Area | Intended contract | Implemented behavior | Drift | Severity | Correction |
|---|---|---|---|---|---|
| Evidence schema | Evidence records selection mode, selected patterns, loaded files, rationale, and authorization source. | `#RootSelectionResponse.evidence` records `rootMCPAvailable`, `selectionMode`, and `indexSources`; selected entries record pattern ids, loadable files, matched terms, and rationale. | Loaded files and authorization source are not first-class evidence fields; they are inferable from selected entries and index sources. | Medium | Add typed `evidence.loadedFiles` and `evidence.authorizationSource` fields, then populate them from selected entries/root mediation. |
| Fallback proof | Fallback mode is bounded and testable. | Prompt text says fallback may use explicitly named AGENTS.cue/index files or user-granted paths; schema allows `fallback-metadata` and `explicit-user-grant`. | Fallback constraints are partly prose; no fixture demonstrates `fallback-metadata` or `explicit-user-grant` limits. | Medium | Add a bounded fallback fixture that records user-granted paths/index files and forbidden loads without expanding runtime behavior. |
| Root mediation | Root brokers task-pattern selection and exposes selected context. | `rootAgentContract` indexes only `nodes/workspace/AGENTS.cue`; `rootSelectionResponse` exports selected context. | Root operations include `searchKeywords`, which is acceptable as declared metadata search but could be misread as filesystem search without stronger policy wording. | Low | Clarify in schema/docs that `agentnode.searchKeywords` searches declared node metadata only. |
| Node metadata authority | Node metadata declares relevance, ownership, support files, forbidden loads, and workflow requirements. | Workspace node declares keywords and task patterns with `owns`; exported response repeats loadable files. | No hard typed relation requires `selected.loadableFiles` to derive from `taskPatterns[].path`/`owns`; current fixture is manually aligned. | Medium | Add CUE constraints or projection helpers that derive selected loadable files from task pattern refs. |
| Policy placement | Policy remains root-owned, typed, auditable, testable. | Forbidden loads are typed and exported; prompt also carries policy statements. | Prompt policy is useful but partially duplicates policy in prose. | Low | Keep prompt as projection output, but source future policy statements from typed fields where possible. |
| Pattern card shape | Selected patterns derive loadable files. | Workspace pattern files each declare their own `authority.loadableFiles`; root response uses the same paths plus node AGENTS.cue. | Pattern files are not constrained by an AgentNode pattern schema and are not referenced directly by `rootSelectionResponse`. | Medium | Introduce a small typed task-pattern card schema or bind pattern exports to `#TaskPatternRef` without changing routing behavior. |

## Boundary Violations

| Violation | Layer | Evidence | Why it matters | Proposed fix |
|---|---|---|---|---|
| Authorization source is not explicit in evidence. | Policy / root authority | `#RootSelectionResponse.evidence` only has `rootMCPAvailable`, `selectionMode`, and `indexSources`; exported responses do not include `authorizationSource`. | Reviewers cannot distinguish root contract authorization from fallback/user grant without interpreting prose or context. | Add a typed `authorizationSource` enum/string to evidence and set it to the root contract path for root-mediated selections. |
| Loaded-file audit is not first-class. | Policy / CUE | Selected entries include `loadableFiles`, but `evidence` does not record actual loaded files. | The fixture proves what may be loaded, not what was loaded by an adapter or agent. | Add `evidence.loadedFiles` and require it to be a subset of selected loadable/support files for proof fixtures. |
| Fallback boundedness is prompt-defined, not fixture-proven. | Agent prompt / policy | `projectedPrompt.text` contains the bounded fallback rule; no exported fallback fixture exercises `fallback-metadata`. | Bounded fallback can drift because validation does not prove the fallback shape. | Add a minimal `fallbackDiscoveryFixture` using explicit index files/user-granted paths and the same forbidden loads. |
| Loadable files are manually repeated. | Node metadata / root authority | `nodes/workspace/AGENTS.cue` task pattern paths and `nodes/workspace/projections.cue` selected loadable files are aligned by manual duplication. | Manual duplication can authorize stale or neighboring files after later edits. | Derive selected `loadableFiles` from `node.authority.taskPatterns[*].path` plus the selected node index file. |
| Pattern card exports are untyped. | CUE / node metadata | `weztermWorkspacePattern` and `nvimSmartSplitsPattern` are plain structs with id, authority.loadableFiles, and workflow.stage. | Unconstrained pattern cards can drift from root selection schema while still exporting. | Add a narrow schema for workspace pattern cards or reuse a typed subset of `#TaskPatternRef`. |

## Enforcement Proof Checklist

| Proof question | Status | Evidence |
|---|---|---|
| Root can select task patterns without broad repo scan. | Partially proven | `rootAgentContract` indexes one contract path and workspace metadata declares keywords; `rootSelectionResponse.objective` states no broad filesystem discovery. There is no runtime proof, which is correct for CUE, but the metadata path is bounded. |
| Selected pattern IDs are present in exported responses. | Proven | `rootSelectionResponse.selected[].patternID` exports `wezterm.workspace` and `nvim.smart-splits`. |
| Selected patterns derive loadable files. | Partially proven | Exported selected entries include loadable pattern files, and pattern cards declare matching `authority.loadableFiles`; derivation is manual, not enforced. |
| Arbitrary neighboring files are not implicitly loadable. | Partially proven | Exported loadable files are explicit and narrow; no typed subset rule prevents future accidental neighboring files. |
| Forbidden loads are represented clearly. | Proven | `forbiddenLoads` exports `chezmoi/**`, `**/AGENTS.md recursive`, and `** via unbounded rg --files`. |
| Fallback mode is bounded. | Partially proven | Prompt text bounds fallback to named AGENTS.cue/index files or user-granted paths; no fallback fixture proves this mode. |
| Projected prompt preserves root mediation. | Proven | Exported `projectedPrompt.text` says to use AGENTS.cue/root MCP selections, avoid task-owned files before root mediation, and record fallback mode. |
| Evidence records selection mode, selected patterns, loaded files, rationale, and authorization source. | Partially proven | Selection mode, selected patterns, and rationale are exported. Loaded files are represented as allowed loadable files, and authorization source is inferable from `indexSources`; neither is a first-class evidence field. |

## Validation and Export Evidence

| Command | Result |
|---|---|
| `cue vet .` | Passed with no output. |
| `cue vet ./cue/agentnode/...` | Passed with no output. |
| `cue vet ./nodes/workspace/...` | Passed with no output. |
| `cue vet ./cue/patterns/...` | Passed with no output. |
| `cue export . -e rootAgentContract --out json` | Exported root index with one workspace contract and four bounded AgentNode operations. |
| `cue export ./nodes/workspace -e rootSelectionResponse --out json` | Exported two selected patterns, explicit loadable files, forbidden loads, and root-mediated evidence. |
| `cue export ./nodes/workspace -e boundedDiscoveryFixture --out json` | Exported the same bounded root-mediated selection fixture with forbidden loads pinned. |
| `cue export ./nodes/workspace -e projectedPrompt.text --out text` | Exported prompt text preserving root mediation and bounded fallback. |

## Correction Plan Before Further Feature Work

1. Freeze current feature surface at routing metadata, selection response, bounded fixture, and projected prompt only.
2. Add typed evidence fields for `authorizationSource` and `loadedFiles`; require fixture evidence to list loaded files separately from loadable files.
3. Derive selected `loadableFiles` from selected task pattern refs and node index files instead of manually repeating paths.
4. Add a minimal typed workspace pattern-card schema so pattern exports cannot drift from root selection expectations.
5. Add one bounded fallback fixture that proves `fallback-metadata` without adding runtime behavior or new planning.
6. Clarify that `agentnode.searchKeywords` means declared metadata keyword matching only, not filesystem search or semantic search.
7. Keep prompt text as a projection of root-owned policy; avoid adding independent prose policy outside typed CUE fields.
