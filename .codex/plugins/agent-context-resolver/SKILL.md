---
name: dotfiles-agent-context-resolver
description: Resolve bundled dotfiles repository context and compile bounded route packets.
---

# Dotfiles Agent Context Resolver

This plugin is self-contained at runtime. It uses bundled JSON projections plus `sh` and `jq`.

## Runtime rules

1. Treat the `UserPromptSubmit` hook output as bounded context, not task authority.
2. Use `selectedFragments` as the admitted fragment subset for the turn.
3. Use `controller.routes` as route summaries for default/compact mode.
4. Inspect only route-declared files unless the user explicitly expands scope.
5. Providers in `provider_inventory.json` are declarations only; do not execute MCP, LSP, A2A, SDK, or external repo lookups from the hook.
6. Do not resume large Codex sessions. Start fresh from the emitted route packet.
7. Return structured validation evidence and stop after the selected task.

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
