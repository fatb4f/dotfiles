# frame

Frame is the active Codex runtime projection.

This tree installs the Frame runtime under `$CODEX_HOME/tools/frame` and keeps
Hookrail only as compatibility / rollback lineage.

## Active surface

- `frame hook run`
- `frame doctor`
- `frame generate`
- `frame hookrail ...` for compatibility

## Projected shape

- `$CODEX_HOME/tools/frame/bin/frame`
- `$CODEX_HOME/tools/frame/bin/frame-hook`
- `$CODEX_HOME/tools/frame/bin/frame-doctor`
- `$CODEX_HOME/tools/frame/bin/hookrail`
- `$CODEX_HOME/tools/frame/bin/cuerail-*`

## Hooks

Use `config/frame.config.toml` for Codex hook wiring. It keeps the same hook
scope as the old Hookrail tree:

- `SessionStart`
- `UserPromptSubmit`
- `PostToolUse`
- `Stop`
