# hookrail-stripped

A stripped fragment tree for Codex hook-schema / CUE / token-ergonomics work.

This is **not** a relaunch of the archived `frame` repo and **not** the full
`cuerail` runtime. It is a small, portable extraction of the parts that support
bounded context, turn/session pressure, hook output validity, and durable
artifact capture.

## Keep / port

```text
- CUE validates official Codex hook-shaped inputs and outputs
- CUE normalizes hook events into a small manifest
- capture policy decides what is persisted
- persisted evidence is separate from bounded live agent feedback
- writes use temp-file + atomic rename
- hook stdout must always be valid native hook JSON
- doctor/checker validates fixtures and output shape
```

## Do not port

```text
- full archived frame runtime
- full cuerail install tree
- MCP-first capture architecture
- repo-git / repo-rg transport assumptions
- PTY runner
- legacy FRAME_HOME naming
- opaque memory/daemon side rail
```

## Initial hook scope

```text
SessionStart
UserPromptSubmit
PostToolUse
Stop
```

## Runtime contract

`hookrail` can run without persistence. If `HOOKRAIL_STATE` is set, selected
manifests are persisted under:

```text
$HOOKRAIL_STATE/runs/<session_id>/<turn_id>/events/
```

For hooks without `turn_id`, `session` is used as the synthetic turn id.

## Thresholds

```text
HOOKRAIL_PROMPT_LARGE_CHARS       default: 50000
HOOKRAIL_PROMPT_OVERSIZED_CHARS   default: 100000
HOOKRAIL_TOOL_LARGE_CHARS         default: 50000
HOOKRAIL_AGENT_FEED_CHARS         default: 2000
```

## Smoke test

```sh
bin/hookrail-doctor
```

Manual hook run:

```sh
bin/hookrail-hook < fixtures/hooks/user-prompt-submit-large.json
```

With persistence:

```sh
HOOKRAIL_STATE=/tmp/hookrail-state bin/hookrail-hook < fixtures/hooks/post-tool-use-large.json
find /tmp/hookrail-state -type f -maxdepth 6
```

## Codex config.toml wiring

Hookrail includes a ready-to-append config fragment:

```text
config/hookrail.config.toml
```

Install into a Codex home:

```sh
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
./scripts/install-to-codex-home --append-config
```

This installs runtime files under:

```text
$CODEX_HOME/tools/hookrail
```

and appends hook wiring to:

```text
$CODEX_HOME/config.toml
```

The wired hooks are:

```text
SessionStart
UserPromptSubmit
PostToolUse
Stop
```

Codex loads hooks from inline `[hooks]` tables in `config.toml`. Project-local hook config is also supported under `<repo>/.codex/config.toml`, but it only loads once the project `.codex/` layer is trusted.
