# Frame Manifest

## Owned surface

| Surface | Path |
|---|---|
| Runtime projection | `$CODEX_HOME/tools/frame` |
| Active hook command | `$CODEX_HOME/tools/frame/bin/frame` |
| Hook scope | `SessionStart`, `UserPromptSubmit`, `PostToolUse`, `Stop` |
| Legacy line | `hookrail` is rollback-only compatibility |

## Source fragments

```text
README.md
config/frame.config.toml
bin/symlink_frame.tmpl
scripts/executable_install-to-codex-home
```

## Notes

The install helper copies the Frame repository into the runtime root and can
append the hook fragment to `$CODEX_HOME/config.toml`.
