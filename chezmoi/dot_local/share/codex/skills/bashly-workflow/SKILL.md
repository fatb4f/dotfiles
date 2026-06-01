---
name: bashly
description: "Use for Bashly source-edit workflow work: Bashly config/source inspection, generated artifact boundaries, local CI validation, and CLI behavior reasoning."
---

# Bashly source-edit workflow

Use this skill when work involves Bashly configuration, Bashly source scripts, generated CLI behavior, or validation of a Bashly project.

## Contract

Bashly source editing means:

```txt
inspect Bashly config and source
edit source/config only when needed
```

Generated Bashly output is reproducible. Inspect and execute it as evidence, but do not manually patch it as the durable fix.

## Validation authority


Current required order:

```txt
shellharden
shfmt
shellcheck source
bashly generate
```

