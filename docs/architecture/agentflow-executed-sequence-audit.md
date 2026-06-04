# Agentflow Executed Sequence Audit

Status: feature work frozen. No CUE contracts were added or modified by this audit.

## Scope

Target commits:

- `d15a5b25a6af566bae428afab3e09e8c4a91e940` / `d15a5b2 Add typed Git contract`
- `f6e2d72caf32626dbf202d0d7e5c1d07fa6e5f14` / `f6e2d72 feat(git-workflow): bind MCP evidence projection`

Primary evidence:

- Codex session log for `d15a5b2`: `/home/_404/.local/share/codex/sessions/2026/06/03/rollout-2026-06-03T20-29-24-019e9008-ed8e-7e80-9af6-91d17a2a16ad.jsonl`
- Codex session log for `f6e2d72`: `/home/_404/.local/share/codex/sessions/2026/06/03/rollout-2026-06-03T20-35-50-019e900e-d08f-7140-b6c4-ece7b85b3370.jsonl`
- Git MCP metadata and committed diffs from `git_show` for both target commits.
- Validation report: `var/run/hookrail/validation-report.latest.json`.
- Shell history check: `/home/_404/.bash_history` had no matches for the target hashes, CUE commands, or Git MCP command names; `/home/_404/.zsh_history` was absent.

Loaded files for this audit:

- `AGENTS.cue`
- `AGENTS.md`
- `/home/_404/.local/share/codex/skills/file-search/SKILL.md`
- `/home/_404/.local/share/codex/skills/git-workflow/SKILL.md`
- `/home/_404/.local/share/codex/skills/git-workflow/references/tasks/discovery.md`
- `/home/_404/.local/share/codex/skills/git-workflow/references/tasks/closeout.md`
- `/home/_404/.local/share/codex/skills/data-tools/SKILL.md`
- The two Codex JSONL session logs listed above.
- `var/run/hookrail/validation-report.latest.json`

Denied or avoided loads:

- `/home/_404/src/.codex/**`, `/home/_404/src/.agents/**`, `/home/_404/src/frame/**`, and unbounded `/home/_404/src/*` sibling scans were avoided because `AGENTS.cue` selects `dotfiles` by default and denies unselected sibling/config loads.
- No `cue/contracts/agentflow` path was created or read.

## Raw Ordered Event Timeline

### Commit `d15a5b2`

| Order | Time UTC | Event | Evidence |
|---:|---|---|---|
| 1 | 00:29:35 | Path discovery listed `AGENTS.cue`, CUE pattern files, and no existing `cue/contracts` tree. | session line 12, output line 15 |
| 2 | 00:29:44 | Read `AGENTS.cue`, `cue/patterns/domain/schema.cue`, `cue/patterns/projections/codex-slice.cue`, `cue/patterns/domain/git.cue`. | session lines 22-25, outputs 27-30 |
| 3 | 00:29:58 | Ran `cue eval ./cue/patterns/domain ./cue/patterns/projections`; it succeeded. | session line 50, output 53 |
| 4 | 00:31:11 | First mutation: `apply_patch` added `cue/contracts/git/*.cue`, fixtures, and edited `cue/patterns/domain/git.cue`. | session line 58 |
| 5 | 00:31:17 | Ran `cue vet ./cue/contracts/git/...` and `cue vet ./cue/patterns/...`. | session lines 66-67 |
| 6 | 00:31:31 | Re-ran `cue vet ./cue/contracts/git/...` and `cue vet ./cue/patterns/...`. | session lines 82-83 |
| 7 | 00:31:39 | Exported `good`, `badWorkflowAuthority`, and first selected workflow projection `generatedCliChangeCodexSlice`. | session lines 91-93, output 97 |
| 8 | 00:32:06 | Ran failed exploratory CUE export/unification and `cue eval ./cue/contracts/git -e '#GitContract' -c=false`. | session lines 128-129 |
| 9 | 00:32:14 | Ran failed package-combined export/unification check. | session line 136, output 137 |
| 10 | 00:33:02 | Additional mutation: `apply_patch` changed Git contract topology/evidence fields. | session line 143 |
| 11 | 00:33:10 | Formatted, ran CUE vets, and exported `good`; contract vet/export failed on `worktreeGate`. | session lines 151-158 |
| 12 | 00:33:16 | Additional mutation: `apply_patch` fixed `#GitGates`. | session line 164 |
| 13 | 00:33:23 | Re-ran CUE vets and fixture exports; succeeded. | session lines 170-177 |
| 14 | 00:33:30 | Exported `generatedCliChangeCodexSlice` to `/tmp` and checked Git MCP status/diffs. | session lines 183-193 |
| 15 | 00:33:39 | Staged scoped files through Git MCP. | session lines 199-201 |
| 16 | 00:33:42 | Reviewed staged diff and status through Git MCP. | session lines 205-210 |
| 17 | 00:33:46 | Committed `d15a5b2 Add typed Git contract`. | session lines 215-217; Git MCP `git_show` |
| 18 | 00:33:50 | Final Git MCP status/diff checks reported clean worktree. | session lines 223-231 |

### Commit `f6e2d72`

| Order | Time UTC | Event | Evidence |
|---:|---|---|---|
| 1 | 00:36:01 | Path discovery and skill reads. | session lines 11-16 |
| 2 | 00:36:08 | Read `AGENTS.cue` and git workflow discovery/closeout task docs. | session lines 22-27 |
| 3 | 00:36:20 | Git MCP status reported clean; path/text discovery found existing Git contract files. | session lines 36-42 |
| 4 | 00:36:29 | Read `schema.cue`, `worktree.cue`, `evidence.cue`, `patch_stack.cue`. | session lines 47-54 |
| 5 | 00:36:39 | Read `fixtures/good.cue`, `fixtures/bad.cue`, `cue/patterns/domain/git.cue`, `domain/schema.cue`, and `codex-slice.cue`. | session lines 58-67 |
| 6 | 00:36:57 | Ran baseline `cue vet ./cue/contracts/git/...`; it passed. | session line 79, agent note line 85 |
| 7 | 00:38:15 | First mutation: `apply_patch` added `cue/contracts/git/projections/mcp_evidence.cue` and MCP worktree fixtures, and updated `bad.cue`. | session line 112 |
| 8 | 00:38:27 | Ran CUE vet and first targeted exports for `mcpWorktreeGood`, `mcpWorktreeBad`, and `badWorkflowAuthorityFixturePattern`. | session lines 128-131 |
| 9 | 00:38:43 | Re-ran `cue vet ./cue/contracts/git/...`. | session line 148 |
| 10 | 00:38:48 | Ran `cue vet -c ./cue/contracts/git/...` to inspect concreteness. | session line 155 |
| 11 | 00:39:01 | Re-ran CUE vet and exports; `mcpWorktreeGood` exported with `accepted: true`, `mcpWorktreeBad` with `accepted: false`. | session lines 169-177 |
| 12 | 00:39:11 | Additional mutation: fixed projection topology self-reference. | session line 183 |
| 13 | 00:39:17 | Exported `mcpWorktreeGood` with targeted checks and `badWorkflowAuthorityFixturePattern`. | session lines 189-192 |
| 14 | 00:39:26 | Final CUE vet and targeted exports passed; `mcpWorktreeGood.accepted == true`. | session lines 197-204 |
| 15 | 00:39:31 | Git MCP status/diffs showed unstaged scoped changes. | session lines 210-218 |
| 16 | 00:39:38 | Staged four scoped CUE files through Git MCP. | session lines 224-226 |
| 17 | 00:39:43 | Reviewed staged diff/status through Git MCP. | session lines 230-235 |
| 18 | 00:39:48 | Committed `f6e2d72 feat(git-workflow): bind MCP evidence projection`. | session lines 241-243; Git MCP `git_show` |
| 19 | 00:39:53 | Final Git MCP status/diff checks reported clean worktree. | session lines 247-255 |

## First Mutation Event

Overall first mutation in the audited sequence:

- `2026-06-04T00:31:11.187Z`, session line 58, `apply_patch`.
- It added the initial typed Git contract files under `cue/contracts/git/` and updated `cue/patterns/domain/git.cue`.

Per target commit:

- `d15a5b2`: first mutation was session line 58 at `00:31:11`.
- `f6e2d72`: first mutation was session line 112 at `00:38:15`.

## CUE Events Before First Mutation

### `d15a5b2` before line 58

- Read/path discovery of CUE files: `rg --files ... '*.cue'`, session line 12, output line 15.
- Read `AGENTS.cue`: session line 22, output line 27.
- Read `cue/patterns/domain/schema.cue`: session line 23, output line 28.
- Read `cue/patterns/projections/codex-slice.cue`: session line 24, output line 29.
- Read `cue/patterns/domain/git.cue`: session line 25, output line 30.
- Searched CUE pattern/projection files for schema/contract terms: session line 36, output line 40.
- Read additional `cue/patterns/domain/schema.cue` range and `cue.mod/module.cue`: session lines 37-38, outputs 41-42.
- Ran `cue eval ./cue/patterns/domain ./cue/patterns/projections`: session line 50, output line 53.

No selected projection export occurred before the first mutation.

### `f6e2d72` before line 112

- Path discovery under CUE contract/pattern paths: session line 37, output line 41.
- CUE text discovery under existing Git contract and Git card: session line 38, output line 42.
- Read `cue/contracts/git/schema.cue`: session line 47, output line 51.
- Read `cue/contracts/git/worktree.cue`: session line 48, output line 52.
- Read `cue/contracts/git/evidence.cue`: session line 49, output line 53.
- Read `cue/contracts/git/patch_stack.cue`: session line 50, output line 54.
- Read `cue/contracts/git/fixtures/good.cue`: session line 58, output line 63.
- Read `cue/contracts/git/fixtures/bad.cue`: session line 59.
- Read `cue/patterns/domain/git.cue`: session line 60, output line 65.
- Read `cue/patterns/domain/schema.cue`: session line 61.
- Read `cue/patterns/projections/codex-slice.cue`: session line 62, output line 67.
- Ran `cue vet ./cue/contracts/git/...`: session line 79, described as passing at session line 85.

No selected projection export occurred before the first mutation.

## CUE Events After First Mutation

### `d15a5b2` after line 58

- `cue vet ./cue/contracts/git/...`: session lines 66, 82, 152, 170.
- `cue vet ./cue/patterns/...`: session lines 67, 83, 153, 171.
- `cue export ./cue/contracts/git/fixtures -e good --out json`: session lines 91, 154, 172.
- `cue export ./cue/contracts/git/fixtures -e badWorkflowAuthority --out json`: session lines 92, 173.
- `cue export ./cue/patterns/projections -e generatedCliChangeCodexSlice --out json`: session line 93, output line 97.
- `cue export ./cue/contracts/git/fixtures -e 'badWorkflowAuthority.candidate & git.#GitContract' --out json`: session line 128, failed.
- `cue eval ./cue/contracts/git -e '#GitContract' -c=false`: session line 129.
- `cue export ./cue/contracts/git ./cue/contracts/git/fixtures -e 'badWorkflowAuthority.candidate & #GitContract' --out json`: session line 136, failed.
- `cue export ./cue/patterns/projections -e generatedCliChangeCodexSlice --out json >/tmp/generatedCliChangeCodexSlice.json`: session line 183.

### `f6e2d72` after line 112

- `cue vet ./cue/contracts/git/...`: session lines 128, 148, 169, 197.
- `cue vet -c ./cue/contracts/git/...`: session line 155.
- `cue export ./cue/contracts/git/fixtures -e mcpWorktreeGood --out json`: session lines 129, 170, 189, 198.
- `cue export ./cue/contracts/git/fixtures -e mcpWorktreeBad --out json`: session lines 130, 171, 199.
- `cue export ./cue/contracts/git/fixtures -e badWorkflowAuthorityFixturePattern --out json`: session lines 131, 190, 200.
- `cue export ./cue/contracts/git/fixtures -e badWorkflowAuthority --out json`: session line 172.

## Projection Questions

Selected projection exported before mutation: no.

- `d15a5b2`: the first `generatedCliChangeCodexSlice` export was session line 93, after first mutation line 58.
- `f6e2d72`: no selected workflow projection export occurred before first mutation line 112. The first MCP evidence projection export occurred after mutation, at session line 129/170.

Selected projection accepted before mutation: no.

- No pre-mutation selected projection export exists in either commit-producing session, so no accepted projection result existed before mutation.
- `f6e2d72` accepted projection evidence appears only after mutation: `mcpWorktreeGood` exported with `accepted: true` at session output lines 175 and 202.

Mutation scope derived from that projection: no.

- The mutation scope for `d15a5b2` was derived from the user prompt and the existing Git domain card/schema reads, not from an exported/accepted projection. Evidence: session user prompt line 7 proposed the exact `cue/contracts/git/*.cue` split; first projection export was later at line 93.
- The mutation scope for `f6e2d72` was derived from the user prompt and existing Git contract files. Evidence: user prompt line 7 named the MCP evidence projection slice and files; first mutation line 112 created those files before any projection export.

## Git Metadata And Committed Artifact Evidence

`d15a5b2` committed:

- New `cue/contracts/git/evidence.cue`
- New `cue/contracts/git/fixtures/bad.cue`
- New `cue/contracts/git/fixtures/good.cue`
- New `cue/contracts/git/patch_stack.cue`
- New `cue/contracts/git/schema.cue`
- New `cue/contracts/git/worktree.cue`
- Modified `cue/patterns/domain/git.cue`

Evidence: Git MCP `git_show d15a5b25a6af566bae428afab3e09e8c4a91e940`.

`f6e2d72` committed:

- Modified `cue/contracts/git/fixtures/bad.cue`
- New `cue/contracts/git/fixtures/mcp_worktree_bad.cue`
- New `cue/contracts/git/fixtures/mcp_worktree_good.cue`
- New `cue/contracts/git/projections/mcp_evidence.cue`

Evidence: Git MCP `git_show f6e2d72caf32626dbf202d0d7e5c1d07fa6e5f14`.

## Validation Reports

`var/run/hookrail/validation-report.latest.json` records a later validation report generated by:

- `cue export ./cue/patterns/projections -e cueFlowValidationReportManifest --out json`

It lists validation/export commands for pattern projections, including:

- `cue vet .`
- `cue vet ./cue/agentnode/...`
- `cue vet ./nodes/workspace/...`
- `cue vet ./cue/patterns/...`
- exports for `cueFlowFactRootedRelationSlice`, `cueFlowAuthorizationEvidenceSlice`, `cueFlowPromotionByUnificationSlice`, `cueFlowPromotedProjectionBindingSlice`, `cueFlowValidationAssessmentSlice`, and `cueFlowValidationReportManifest`.

This report supports that CUE projection validation machinery existed, but it does not prove either target commit exported or accepted a selected projection before mutation.

## Contract Fields Required By Observed Delta

Observed deltas require an eventual audit contract to represent:

- `objective`
- `sessionID`
- `sessionPath`
- `commitSHA`
- `commitMessage`
- `eventLine`
- `timestamp`
- `eventKind`
- `toolName`
- `command`
- `targetPaths`
- `cueReadsBeforeMutation`
- `cueExportsBeforeMutation`
- `cueVetsBeforeMutation`
- `cueReadsAfterMutation`
- `cueExportsAfterMutation`
- `cueVetsAfterMutation`
- `firstMutation`
- `selectedProjectionName`
- `selectedProjectionExportedBeforeMutation`
- `selectedProjectionAcceptedBeforeMutation`
- `mutationScopeDerivedFromProjection`
- `evidenceSources`
- `loadedFiles`
- `deniedLoads`
- `validationEvidence`
- `shellHistoryEvidence`
- `gitMetadataEvidence`

## Closeout Summary

actual sequence: read repo contract and relevant CUE files; run CUE eval/vet baseline; mutate CUE; run CUE vet/export validation; export projection only after mutation; stage/review/commit through Git MCP.

first mutation: `d15a5b2` session line 58, `2026-06-04T00:31:11.187Z`, `apply_patch` adding `cue/contracts/git/*` and editing `cue/patterns/domain/git.cue`.

projection before mutation: no.

projection accepted before mutation: no.

mutation scope derived from projection: no.

contract fields required by observed delta: listed in the previous section.
