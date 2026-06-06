# AGENTS.md

## Required workflow

Use this sequence for retrieval-phase work:

```text
user turn
→ prompt
→ spatial awareness
→ discover AGENTS.md
→ AGENTS.md bootstraps CUE MCP / RALPH
→ load cue/root/* root contract
→ check .codex/context.cue status
```

## Local context cache boundary

`.codex/nodes/*` is normalized local node-context cache.
`.codex/context.cue` is the generated rollup/index over local context.
`.codex/manifests/*` stores evidence proving how `.codex/nodes` and `.codex/context.cue` were generated.
None of these surfaces may grant authority, load admissibility, mutation admissibility, execution permission, or policy.

Compact invariant:

```text
.codex/nodes is memory, not law.

R may read it to avoid rebuilding local context.
R may refresh it through bounded observation.
cue/root validates its shape.
.codex/manifests proves its generation.
No authority flows out of .codex/nodes.
```

Reject these cache/context states:

- `.codex/nodes/*` contains root authority.
- `.codex/nodes/*` grants load admissibility.
- `.codex/nodes/*` grants mutation admissibility.
- `.codex/nodes/*` claims execution permission.
- `.codex/nodes/*` contains reusable policy.
- `.codex/nodes/*` contains global invariants.
- `.codex/context.cue` treats `.codex/nodes` as authority.
