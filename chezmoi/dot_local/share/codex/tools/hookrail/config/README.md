# Hookrail Codex config wiring

Codex can load lifecycle hooks from inline `[hooks]` tables in `config.toml`.

Use `hookrail.config.toml` as the config fragment for this stripped tree.

## User-level install

```sh
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
./scripts/install-to-codex-home --append-config
```

This installs the hook scripts to:

```text
$CODEX_HOME/tools/hookrail
```

and appends the hook block to:

```text
$CODEX_HOME/config.toml
```

The hook adapters execute the deployed Bashly CLI at:

```text
$CODEX_HOME/tools/hookrail/bin/hookrail
```

That deployed CLI resolves its CUE module from:

```text
$CODEX_HOME/cue.mods/hookrail
```

## Project-local install

Copy `config/hookrail.config.toml` into:

```text
<repo>/.codex/config.toml
```

Project-local hooks load only when the project `.codex/` layer is trusted.

## Active hooks

```text
SessionStart       -> hooks/session-start
UserPromptSubmit   -> hooks/user-prompt-submit
PostToolUse        -> hooks/post-tool-use
Stop               -> hooks/stop
```
