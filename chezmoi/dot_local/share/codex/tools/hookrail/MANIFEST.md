# Extraction manifest

Hookrail is now compatibility only. Frame is the active runtime projection.

## Retained

- `cue.mods/hookrail/hooks.cue`
- `cue.mods/hookrail/output.cue`
- `cue.mods/hookrail/manifest.cue`
- `cue.mods/hookrail/projection.cue`
- `bin/symlink_hookrail.tmpl`
- `bin/executable_hookrail-hook`
- `bin/executable_hookrail-doctor`
- `scripts/install-to-codex-home`

## Active command target

```text
$CODEX_HOME/tools/frame/bin/frame
```

## Hook scope

```text
SessionStart
UserPromptSubmit
PostToolUse
Stop
```
