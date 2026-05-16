---
name: cue
description: Use CUE for dotfile authority, schema validation, projection contracts, and generated-surface checks. Trigger when modifying CUE schemas, domain seeds, projection surfaces, or CUE-vetted reports.
---

# CUE Projection Skill

Use this skill when modifying dotfile projection surfaces.

## Contract

- Treat CUE as the authority plane.
- Treat shell scripts as adapters.
- Keep generated files reproducible from the current authority source, when a generator exists.
- Do not encode Codex profile policy in interactive or noninteractive shell init.
- If no generator exists, treat the checked-in chezmoi source files as authority and remove stale generated headers.

## Expected workflow

```txt
change schema/domain seed or managed source
-> regenerate/project when applicable
-> parse/check generated scripts
-> run doctor/dry-run
```

``
