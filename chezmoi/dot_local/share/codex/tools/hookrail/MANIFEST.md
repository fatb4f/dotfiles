# Extraction manifest

## Source fragments retained

| Fragment | Retained shape |
|---|---|
| CUE hook-schema authority | `cue.mods/hookrail/hooks.cue`, `cue.mods/hookrail/output.cue` |
| Hook manifest pattern | `cue.mods/hookrail/manifest.cue`, Bashly persistence writer |
| Capture policy | `cue.mods/hookrail/projection.cue` |
| AgentFeed distinction | `cue.mods/hookrail/manifest.cue`, bounded `additionalContext` |
| CLI projection | `bin/symlink_hookrail.tmpl` |
| Atomic persistence | Bashly temp file + locked atomic `mv` |
| Safe failure behavior | valid no-op JSON on context hooks when possible |
| Doctor gates | `$CODEX_HOME/tools/hookrail/bin/hookrail doctor` |

## Legacy rollback retained

```text
chezmoi/dot_local/share/codex/tools/hookrail/bin/executable_hookrail-hook
chezmoi/dot_local/share/codex/tools/hookrail/bin/executable_hookrail-doctor
chezmoi/dot_local/share/codex/tools/hookrail/cue/
chezmoi/dot_local/share/codex/tools/hookrail/cue.mod/
```

These files are not the active path. Active hook wrappers call the
Bashly-generated adapter deployed at `$CODEX_HOME/tools/hookrail/bin/hookrail`.

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
