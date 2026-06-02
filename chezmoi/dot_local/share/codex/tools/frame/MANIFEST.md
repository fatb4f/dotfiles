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
scripts/executable_install-to-codex-home
```

## Notes

The install helper is the authority for materializing the runtime tree under
`$CODEX_HOME/tools/frame` and can append the hook fragment to
`$CODEX_HOME/config.toml`.
