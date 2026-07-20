---
name: resolve-agent-context
description: Establish bounded repository context through the CUE-rooted Marimo and DSPy workbook.
---

# Agent Context Resolution

The `UserPromptSubmit` hook is a thin transport adapter over the canonical context workbook.

1. Run `.codex/plugins/agent-context-resolver/scripts/resolve-agent-context --prompt "<prompt>"` for an inspectable context state.
2. Treat `.codex/context-model` as the provisional data authority.
3. Treat `.codex/context-workbook/context-workbook.py` as the canonical executable DAG.
4. Use a projected packet only when `sufficiency.state` is `sufficient` and CUE validation succeeded.
5. Resolve selected fragment, file, provider, workflow, and evidence IDs through the returned state; do not infer omitted context.
6. Never execute routes, promote DSPy output to source authority, forward raw transcripts, or promote MCP/LSP output beyond evidence.
7. The legacy prompt-route registry is migration evidence only. There is no lexical fallback.
8. Regenerate plugin projection descriptors with `python -m context_workbook.projections --repo-root .` after model or workbook changes.
