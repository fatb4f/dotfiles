# Stop Review Ledger

Review only. No implementation, no new router, no `agents.cue` expansion, no stop-hook edits.

## Recent Hook Commit Inventory

### `git log --oneline -n 10`

```text
cc6462547ecdbc9c2b2717da38df72fd70643400 feat(hookrail): add event-specific feed sentinels
055e9d7196444fe66af184a743338f2a9eee7420 fix
eda84636cd6776ef3c49600d9dfe36793d5a2d46 docs(skill): require git-mcp-server for git workflow
15f45f738889722e00fdf6375fad7ef4da013a92 fix(hookrail): deploy stable hook entrypoints
60113f6cc879a02226e7ae90b4b349ef58bdce17 feat(hookrail): surface feed sentinel in session start
7c54c4ad19396e0c3ae4849fce8c71ac2916dad2 fix
c526b0458571de16abc9092dcc8aa7887faf4c4d feat(hookrail): route feed transport through systemMessage
2f803e786e91d2b4d0a177b18ec5920d6fedc4b6 fix
e5e565a97081855e7a969dcdb6cfc02f2eadc4e6 docs: tighten git-workflow skill
a8dc4e06179cfad81468ff9c69a578f55e7b3378 docs: tighten agent guidance
```

### Hook commits in that window

| Commit | Changed files | Why it matters |
| --- | --- | --- |
| `cc6462547ecdbc9c2b2717da38df72fd70643400` | `chezmoi/dot_local/share/codex/private_config.toml`; `chezmoi/dot_local/share/codex/tools/hookrail/MANIFEST.md`; `chezmoi/dot_local/share/codex/tools/hookrail/README.md`; `cue.mods/hookrail/feed_proof.cue`; `cue.mods/hookrail/fixtures/post-tool-use-feed-sentinel.json`; `cue.mods/hookrail/fixtures/session-start-feed-sentinel.json`; `cue.mods/hookrail/fixtures/session-start-no-feed.json`; `cue.mods/hookrail/fixtures/user-prompt-submit-feed-sentinel.json`; `cue.mods/hookrail/projection.cue`; `shell-wrap/src/hookrail/hookrail`; `shell-wrap/src/hookrail/src/lib/doctor.sh`; `shell-wrap/src/hookrail/src/lib/git.sh` | Added event-specific feed sentinels for SessionStart, UserPromptSubmit, and PostToolUse. |
| `15f45f738889722e00fdf6375fad7ef4da013a92` | `chezmoi/dot_local/share/codex/tools/hookrail/MANIFEST.md`; `chezmoi/dot_local/share/codex/tools/hookrail/README.md`; `chezmoi/dot_local/share/codex/tools/hookrail/bin/executable_hookrail-doctor`; `chezmoi/dot_local/share/codex/tools/hookrail/bin/executable_hookrail-hook`; `chezmoi/dot_local/share/codex/tools/hookrail/config/README.md`; `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_post-tool-use`; `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_session-start`; `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_stop`; `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_user-prompt-submit`; `chezmoi/dot_local/share/codex/tools/hookrail/scripts/executable_install-to-codex-home` | Moved hook wrappers and docs onto the deployed Bashly CLI path. |
| `60113f6cc879a02226e7ae90b4b349ef58bdce17` | `cue.mods/hookrail/projection.cue`; `shell-wrap/src/hookrail/hookrail`; `shell-wrap/src/hookrail/src/lib/doctor.sh`; `shell-wrap/src/hookrail/src/lib/git.sh` | Surfaced the feed sentinel in SessionStart frame projection and runtime facts. |
| `c526b0458571de16abc9092dcc8aa7887faf4c4d` | `cue.mods/hookrail/agent_feed.cue`; `cue.mods/hookrail/common.cue`; `cue.mods/hookrail/feed_proof.cue`; `cue.mods/hookrail/fixtures/session-start-feed-sentinel.json`; `cue.mods/hookrail/fixtures/session-start-no-feed.json`; `cue.mods/hookrail/frame.cue`; `cue.mods/hookrail/manifest.cue`; `cue.mods/hookrail/projection.cue`; `shell-wrap/src/hookrail/hookrail`; `shell-wrap/src/hookrail/src/lib/doctor.sh`; `shell-wrap/src/hookrail/src/lib/fallback.sh`; `shell-wrap/src/hookrail/src/lib/hook.sh` | Switched agent feed transport from `additionalContext` to `systemMessage` and added feed proof plumbing. |
| `7c54c4ad19396e0c3ae4849fce8c71ac2916dad2` | `chezmoi/dot_local/share/codex/private_config.toml` | Exposed the shared `HOOKRAIL_FEED_SENTINEL` env var. |
| `055e9d7196444fe66af184a743338f2a9eee7420` | `AGENTS.md`; `chezmoi/dot_local/share/codex/tools/hookrail/bin/symlink_hookrail.tmpl` | Locked git usage to git-mcp and added the symlink template for CLI deployment. |

## Current Ownership

### UserPromptSubmit

- Current ownership is bounded prompt transport, not a router or memory layer.
- `shell-wrap/src/hookrail/src/lib/git.sh` selects `HOOKRAIL_USER_PROMPT_FEED_SENTINEL` first, then the shared fallback, and writes `.hookrail.feedSentinel`.
- `cue.mods/hookrail/projection.cue` gives UserPromptSubmit either a feed sentinel `systemMessage` or a bounded compact report when no sentinel is set.
- `cue.mods/hookrail/projection.cue` keeps capture scoped to the event: small prompts stay metadata-only, larger prompts can persist.
- `cue.mods/hookrail/feed_proof.cue` and `shell-wrap/src/hookrail/src/lib/doctor.sh` verify the feed sentinel path for UserPromptSubmit.
- `shell-wrap/src/hookrail/src/lib/fallback.sh` keeps the normal suppress-output fallback behavior for this event.

### PostToolUse

- Current ownership is bounded tool-response transport, not a broad tool broker.
- `shell-wrap/src/hookrail/src/lib/git.sh` selects `HOOKRAIL_POST_TOOL_FEED_SENTINEL` first, then the shared fallback, and writes `.hookrail.feedSentinel`.
- `cue.mods/hookrail/projection.cue` gives PostToolUse either a feed sentinel `systemMessage` or a bounded compact report when no sentinel is set.
- `cue.mods/hookrail/projection.cue` keeps capture scoped to the event: large tool responses can persist, small ones stay trace-only.
- `cue.mods/hookrail/feed_proof.cue` and `shell-wrap/src/hookrail/src/lib/doctor.sh` verify the feed sentinel path for PostToolUse.
- `shell-wrap/src/hookrail/src/lib/fallback.sh` is special-cased so PostToolUse returns `continue` plus `systemMessage` without `suppressOutput` on fallback.

## Control-Surface Table

| surface | current files | owns | must not own | current risk | recommendation |
| --- | --- | --- | --- | --- | --- |
| Codex hook wrappers | `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_session-start`; `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_user-prompt-submit`; `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_post-tool-use`; `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_stop` | Tiny exec shims into the deployed Bashly CLI path. | CUE semantics, issue policy, frame logic, or any router-like branching. | Wrapper drift can reintroduce path confusion or make legacy binaries look active. | Keep wrappers minimal and mechanically identical except for hook name. |
| UserPromptSubmit | `shell-wrap/src/hookrail/src/lib/git.sh`; `shell-wrap/src/hookrail/src/lib/doctor.sh`; `shell-wrap/src/hookrail/src/lib/fallback.sh`; `cue.mods/hookrail/projection.cue`; `cue.mods/hookrail/feed_proof.cue` | Prompt sizing, sentinel selection, bounded system message, metadata-only capture for small prompts. | Stop gate policy, closeout evidence, SessionStart frame injection, new router surfaces. | The event now has two branches: sentinel and compact report. That can drift into a router if it keeps growing. | Freeze the contract now and only tighten the existing branches. |
| PostToolUse | `shell-wrap/src/hookrail/src/lib/git.sh`; `shell-wrap/src/hookrail/src/lib/doctor.sh`; `shell-wrap/src/hookrail/src/lib/fallback.sh`; `cue.mods/hookrail/projection.cue`; `cue.mods/hookrail/feed_proof.cue` | Tool-response sizing, sentinel selection, bounded summary, large-output capture. | Prompt-only policy, Stop recursion logic, closeout evidence, old-frame revival. | The no-suppressOutput fallback is event-specific and easy to accidentally broaden. | Keep this event bounded and do not split it into more sub-surfaces. |
| Stop | `shell-wrap/src/hookrail/src/lib/hook.sh`; `shell-wrap/src/hookrail/src/lib/git.sh`; `shell-wrap/src/hookrail/src/lib/fallback.sh`; `shell-wrap/src/hookrail/src/lib/doctor.sh`; `cue.mods/hookrail/projection.cue`; `chezmoi/dot_local/share/codex/private_config.toml`; `chezmoi/dot_local/share/codex/tools/hookrail/hooks/executable_stop` | Dirty-repo closeout gate, recursion guard, and current `git-closeout.json` acceptance. | Session frame injection, feed sentinels, issue management, new router surfaces. | Stop already mixes gate logic with frame lineage, which is the shortest path back to the archived frame pattern. | Do not modify stop hooks in the next slice; keep the gate frozen. |
| CUE hookrail module | `cue.mods/hookrail/common.cue`; `cue.mods/hookrail/output.cue`; `cue.mods/hookrail/manifest.cue`; `cue.mods/hookrail/projection.cue`; `cue.mods/hookrail/agent_feed.cue`; `cue.mods/hookrail/feed_proof.cue`; `cue.mods/hookrail/frame.cue`; `cue.mods/hookrail/hooks.cue` | Semantic contracts, output shape, feed proof, trace row shape, frame projection. | Runtime deployment, GitHub issue workflow, wrapper pathing, archived frame repo patterns. | `frame.cue` and the `context_frame` path are the biggest duplication seam in the module. | Do not add new CUE router files or expand `agents.cue`; tighten only what already exists. |
| GitHub issue tracker | Issues `#3` through `#31` | Planning and triage only. | Source-of-truth runtime architecture. | The issue stack is now a parallel design surface, which invites churn. | Collapse verified slice issues first and demote the frame-heavy ones to notes. |

## GitHub Issue Sprawl Inventory

Classification is based on current repo evidence, not labels.

### Landed / verify only

- `#20` Hookrail slice 1: add canonical CUE module and projection entrypoint.
- `#21` Hookrail slice 1: add Bashly command surface under shell-wrap.
- `#22` Hookrail slice 1: implement manifest persistence mechanics in Bashly adapter.
- `#23` Hookrail slice 1: replace doctor with CUE-first Bashly checks.
- `#24` Hookrail slice 1: migrate Codex hook wrappers to Bashly-generated adapter.
- `#25` Hookrail slice 1: demote Python adapter after Bashly+CUE path is green.
- `#26` Hookrail correctness: derive runtime facts before CUE Stop projection.
- `#27` Hookrail correctness: make doctor prove the active Bashly runtime path.
- `#28` Hookrail lifecycle: restore active invocation trace append.

### Repo-local operational bug

- `#29` Hookrail lifecycle: add first-class closeout evidence artifact.

### Design / reference note

- `#11` Contract: CUE-owned workspace lifecycle for git-ws/chezmoi/sessionizer integration.
- `#13` Hookrail: defer CUE runtime authority until hook lifecycle is end-to-end.
- `#14` Hookrail slice: generate git closeout evidence artifact.
- `#15` Hookrail slice: generate closeout and fresh-session handoff projection.
- `#16` Hookrail slice: prove Stop gate runtime closeout loop.
- `#17` Hookrail slice: SessionStart inject latest closeout handoff.
- `#18` Hookrail slice: promote CUE to validation gate after lifecycle proof.
- `#30` Hookrail context: generate bounded context-frame projection.

### Duplicate / superseded / old-frame gravity

- `#3` through `#10` are the older desktop/workflow backlog and do not belong in the hookrail slice.
- `#12` is a parent tracker and is superseded by its child issues.
- `#19` is the slice-1 umbrella and is superseded by `#20` through `#25`.
- `#31` Hookrail context: inject latest approved frame on SessionStart.

## Frame-Duplication Check

The surfaces that most risk recreating the archived `frame` repo are:

- `cue.mods/hookrail/frame.cue`.
- `hookInput.hookrail.frameText` in `cue.mods/hookrail/common.cue` and `cue.mods/hookrail/projection.cue`.
- The SessionStart frame generation path in `cue.mods/hookrail/projection.cue`.
- The frame persistence path in `shell-wrap/src/hookrail/src/lib/persist.sh`, which writes `context-frame-input.json`.
- The frame-oriented doctor coverage in `shell-wrap/src/hookrail/src/lib/doctor.sh`.
- The legacy rollback adapter in `chezmoi/dot_local/share/codex/tools/hookrail/bin/executable_hookrail-hook`, which still looks for `frames/current.md`.
- `#31`, because "latest approved frame on SessionStart" is the closest conceptual match to the old frame repo.

Current status: the repo has a bounded context-frame projection, but the direct duplication risk remains any move toward a persistent frame repository, a frame router, or a broad memory layer.

## Next-Slice Recommendation

Pick one slice: issue collapse.

Reasoning:

- The hook path is already split across SessionStart, UserPromptSubmit, PostToolUse, and Stop, so adding another runtime layer would increase churn.
- The biggest remaining risk is issue sprawl and frame gravity, not missing router machinery.
- The lowest-risk next move is to collapse the verify-only hookrail slice into one closed set and leave the frame-heavy issues as notes until the current hooks are stable.

Recommended next slice:

- Close or verify-retire `#20` through `#28` as the landed hookrail slice.
- Keep `#29` as the single operational bug.
- Demote `#14`, `#15`, `#17`, `#18`, and `#31` away from active implementation pressure.
- Do not add a new router, new abstractions, or any old-frame port.
