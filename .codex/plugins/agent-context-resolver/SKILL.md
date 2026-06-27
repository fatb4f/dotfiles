---
name: dotfiles-agent-context-resolver
description: Resolve bundled dotfiles repository context and compile bounded route packets.
---

# Dotfiles Agent Context Resolver

This plugin is self-contained at hook runtime. It uses bundled JSON projections plus `sh` and `jq`.

## Runtime rules

1. Treat the `UserPromptSubmit` hook output as bounded context, not task authority.
2. Use `selectedFragments` as the admitted fragment subset for the turn.
3. Use `controller.routes` as route summaries for default/compact mode.
4. Inspect only route-declared files unless the user explicitly expands scope.
5. The hook must not execute MCP, LSP, A2A, SDK, or external repo lookups.
6. LSP providers marked `callable: true` are reachable only through an MCP executor outside the hook and must return structured route-local evidence.
7. Do not resume large Codex sessions. Start fresh from the emitted route packet.
8. Return structured validation evidence and stop after the selected task.

## LSP over MCP

The bundled provider inventory and schema map declare:

- `df:provider/lua-lsp` as an MCP-callable Lua implementation evidence provider.
- `df:provider/cue-lsp` as an MCP-callable CUE graph evidence provider.

Provider output is not implied prompt context and is not source authority. It must be wrapped as evidence and kept inside the selected route boundary.

## Output modes

Default output is compact and quota-bounded. It includes selected fragments, provider IDs/summaries, route summaries, deny rules, and budget.

Full debug output is available only when explicitly requested:

```sh
AGENT_CONTEXT_VERBOSE=1 \
  sh .codex/plugins/agent-context-resolver/scripts/resolve-agent-context \
  --prompt "dotfiles wezterm xplr workspace ide"
```

## CLI

```sh
sh .codex/plugins/agent-context-resolver/scripts/resolve-agent-context \
  --prompt "dotfiles wezterm xplr workspace ide"
```

## Runtime dependencies

- `sh`
- `jq`
- bundled files under `.codex/plugins/agent-context-resolver/generated/`
