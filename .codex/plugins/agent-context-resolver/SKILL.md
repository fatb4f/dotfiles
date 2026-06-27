---
name: dotfiles-agent-context-resolver
description: Resolve bundled dotfiles repository context and compile bounded route packets.
---

# Dotfiles Agent Context Resolver

This plugin is self-contained at runtime. It uses bundled JSON projections plus `sh` and `jq`.

## Runtime rules

1. Treat the `UserPromptSubmit` hook output as bounded context, not task authority.
2. Use `selectedFragments` as a subset of `availableFragmentIDs`.
3. Use `controller.routes` as a subset of `controller.availableRouteIDs`.
4. Inspect only route-declared files unless the user explicitly expands scope.
5. Providers in `provider_inventory.json` are declarations only; do not execute MCP, LSP, A2A, SDK, or external repo lookups from the hook.
6. Do not resume large Codex sessions. Start fresh from the emitted route packet.
7. Return structured validation evidence and stop after the selected task.

## CLI

```sh
sh .codex/plugins/agent-context-resolver/scripts/resolve-agent-context \
  --prompt "dotfiles wezterm xplr workspace ide"
```

## Runtime dependencies

- `sh`
- `jq`
- bundled files under `.codex/plugins/agent-context-resolver/generated/`
