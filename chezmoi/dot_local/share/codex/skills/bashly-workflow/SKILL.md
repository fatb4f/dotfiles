---
name: bashly-workflow
description: "Thin task index for Bashly source/config work, generated shell adapter boundaries, Hookrail executable adapters, validation, generation, and close-out."
when_to_use: Use when AGENTS.md or the user references bashly.discovery, bashly.edit, bashly.validate, bashly.generate, bashly.adapter, bashly.closeout, Bashly source/config work, shell wrapper mechanics, command dispatch, or executable Hookrail adapter behavior.
license: "Repo-local"
compatibility: "Requires Bashly project tooling plus local shell validation tools when available: shellharden, shfmt, shellcheck, bashly."
metadata:
  author: repo-local
  version: "0.1.0"
allowed-tools:
  - Bash(pwd)
  - Bash(rg:*)
  - Bash(fd:*)
  - Bash(ls:*)
  - Bash(shellharden:*)
  - Bash(shfmt:*)
  - Bash(shellcheck:*)
  - Bash(bashly:*)
  - Read
  - Write
---

# Bashly Workflow Skill

This skill is a thin task index for Bashly and shell-wrapper work.

Use it to select the correct Bashly task procedure.

Do not use this skill for Git staging or commits. Use `git-workflow` for Git state.

Do not use this skill for Hookrail CUE contracts, feed shape, or projection semantics. Use the Hookrail/CUE domain authority for that work.

## Core rules

1. Edit Bashly config and source scripts, not generated shell output.
2. Treat generated Bashly output as reproducible evidence.
3. Inspect generated output when needed, but do not manually patch it as the durable fix.
4. Keep command-dispatch and adapter changes task-scoped.
5. Run the smallest relevant validation set.
6. Delegate Git close-out to `git-workflow`.

## Workflow order

```text
bashly.discovery
→ bashly.edit
→ bashly.validate
→ bashly.generate
→ bashly.closeout
```

Executable Hookrail adapter work:

```text
bashly.discovery
→ bashly.adapter
→ bashly.validate
→ bashly.generate
→ bashly.closeout
```

## Tasks

| Order | Task | Use for | Procedure |
|---:|---|---|---|
| 1 | `bashly.discovery` | Inspect Bashly config/source layout and command surface | `references/tasks/discovery.md` |
| 2 | `bashly.edit` | Edit Bashly config or source scripts | `references/tasks/edit.md` |
| 3 | `bashly.validate` | Validate shell source and Bashly project state | `references/tasks/validate.md` |
| 4 | `bashly.generate` | Regenerate Bashly output and inspect generated boundary | `references/tasks/generate.md` |
| 5 | `bashly.adapter` | Inspect executable Hookrail adapter behavior | `references/tasks/adapter.md` |
| 6 | `bashly.closeout` | Produce shell-wrap status/validation handoff for repo close-out | `references/tasks/closeout.md` |

## Cross-skill boundary

Use this skill for:

```text
Bashly config
Bashly source scripts
command dispatch
shell-wrapper mechanics
generated shell adapter boundaries
executable Hookrail adapter behavior
shell validation
```

Use Hookrail/CUE domain authority for:

```text
Hookrail contracts
CUE modules
feed shape
projection semantics
generated hook inputs
manifest semantics
```

Use `git-workflow` for:

```text
git.discovery
git.closeout
staging
commits
final Git status
```

## Skill invariant

```text
AGENTS.md selects a bashly task.
bashly-workflow/SKILL.md maps the task to a task reference.
references/tasks/*.md defines commands, output, and stop conditions.
Bashly source/config is durable.
Generated Bashly output is evidence.
git-workflow owns Git close-out.
```
