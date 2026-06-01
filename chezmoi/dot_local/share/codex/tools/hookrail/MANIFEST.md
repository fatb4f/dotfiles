# Extraction manifest

## Source fragments retained

| Fragment | Retained shape |
|---|---|
| CUE hook-schema authority | `cue/hooks.cue`, `cue/output.cue` |
| Hook manifest pattern | `cue/manifest.cue`, Python manifest writer |
| Capture policy | `cue/capture_policy.cue`, thresholds in `bin/hookrail-hook` |
| AgentFeed distinction | `cue/agent_feed.cue`, bounded `additionalContext` |
| Atomic persistence | temp file + `os.replace()` |
| Safe failure behavior | valid no-op JSON on context hooks when possible |
| Doctor gates | `bin/hookrail-doctor` |

## Explicitly excluded

```text
frame/
FRAME_HOME
repo-frame
full cuerail tree
MCP-first capture
repo-git/repo-rg assumptions
PTY runner
```

## Config wiring added

```text
config/hookrail.config.toml
config/README.md
scripts/install-to-codex-home
```

`hookrail.config.toml` wires these Codex hooks:

```text
SessionStart
UserPromptSubmit
PostToolUse
Stop
```
