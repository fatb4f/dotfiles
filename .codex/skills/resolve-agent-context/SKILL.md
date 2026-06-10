---
name: resolve-agent-context
description: Resolve authoritative CUE task context before inspecting or editing dotfiles capabilities when a hook routing hint names this skill or the resolve-agent-context command.
---

# Agent Context Resolution

The hook hint is not task context. It contains candidate capability IDs only.

Before repository inspection or editing, run the stable resolver:

```sh
/home/_404/src/contract.cuemod/bin/resolve-agent-context \
  --prompt "<current user prompt>" \
  --cwd "$PWD" \
  --candidate "<candidate capability from the hook hint>"
```

Use the returned CUE projection as the task map.

- Resolve first; inspect second.
- Treat hook candidates as hints, never authority.
- Do not invoke `cue cmd` directly or hand-write temporary CUE input.
- Do not infer source/generated boundaries from the hook.
- Do not edit generated `.codex/hooks.json` or `.codex/skills/*`; regenerate them from `contract.cuemod`.
- Run validation commands only when `validation.required` is `true`.
