---
name: agent-sdk 
description: agent-sdk 
---
# agent-sdk

Use this skill when working with repositories or runtime homes managed by `agent-sdk`.

## Runtime commands

```sh
agentctl agent init codex --root "$CODEX_HOME"
agentctl agent generate codex --agents-config "$AGENT_SDK_CONFIG/agents.cue" --root "$CODEX_HOME"
agentctl agent check-generated codex --agents-config "$AGENT_SDK_CONFIG/agents.cue" --root "$CODEX_HOME"
```

## Project commands

```sh
agentctl project init --root .
agentctl project generate --project-root .
agentctl project check-generated --project-root .
```

## Rules

- Treat CUE config as authority.
- Treat runtime files as materialized projections.
- Do not hand-edit generated files.
- Do not delete or adopt unmanaged runtime files unless explicitly requested by a future command.
