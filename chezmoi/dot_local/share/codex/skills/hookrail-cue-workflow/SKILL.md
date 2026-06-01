---
name: hookrail-cue-workflow
description: "Thin task index for Hookrail CUE contracts, projection semantics, agent feed shape, manifest/closeout schemas, fixture validation, and close-out."
when_to_use: Use when AGENTS.md or the user references hookrail-cue.discovery, hookrail-cue.contract, hookrail-cue.projection, hookrail-cue.feed, hookrail-cue.manifest, hookrail-cue.validate, hookrail-cue.closeout, or cue.mods/hookrail CUE work.
license: "Repo-local"
compatibility: "Requires CUE CLI. Git commits must be delegated to git-workflow."
metadata:
  author: repo-local
  version: "0.1.0"
allowed-tools:
  - Bash(pwd)
  - Bash(rg:*)
  - Bash(fd:*)
  - Bash(cue:*)
  - Read
  - Write
---

# Hookrail CUE Workflow Skill

Thin task index for `cue.mods/hookrail`.

Use it to select the correct Hookrail CUE task procedure.

Do not use this skill for shell execution adapters. Use `bashly-workflow` through `shell-wrap/AGENTS.md`.

Do not use this skill for Git staging or commits. Use `git-workflow`.

## Core rules

1. Treat CUE contracts/projections as the authority for Hookrail schema and gating behavior.
2. Keep shell execution behavior out of CUE tasks.
3. Keep generated/runtime evidence out of repo authority unless the task is fixture validation.
4. Use fixtures for validation when schema/projection behavior changes.
5. Do not stage or commit from this skill.

## Workflow order

```text
hookrail-cue.discovery
→ hookrail-cue.contract
→ hookrail-cue.projection
→ hookrail-cue.feed
→ hookrail-cue.manifest
→ hookrail-cue.validate
→ hookrail-cue.closeout
```

## Tasks

| Order | Task | Use for | Procedure |
|---:|---|---|---|
| 1 | `hookrail-cue.discovery` | Inspect CUE module/file layout | `references/tasks/discovery.md` |
| 2 | `hookrail-cue.contract` | Edit Hookrail CUE contracts/schemas | `references/tasks/contract.md` |
| 3 | `hookrail-cue.projection` | Edit projection/gating behavior | `references/tasks/projection.md` |
| 4 | `hookrail-cue.feed` | Edit agent-feed shape or sentinel behavior | `references/tasks/feed.md` |
| 5 | `hookrail-cue.manifest` | Edit manifest or closeout packet schemas | `references/tasks/manifest.md` |
| 6 | `hookrail-cue.validate` | Validate CUE changes with fixtures | `references/tasks/validate.md` |
| 7 | `hookrail-cue.closeout` | Produce CUE/Hookrail handoff for repo close-out | `references/tasks/closeout.md` |

## Cross-skill boundary

Use this skill for:

```text
cue.mods/hookrail/*.cue
Hookrail CUE contracts
projection behavior
agent-feed schema
manifest/closeout packet schema
fixture validation
```

Use `bashly-workflow` for:

```text
shell-wrap/src/hookrail
Bashly config/source
executable hook adapters
command dispatch
shell validation
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
AGENTS.md selects a hookrail-cue task.
hookrail-cue-workflow/SKILL.md maps the task to a task reference.
references/tasks/*.md defines commands, output, and stop conditions.
CUE files own schema/projection semantics.
Shell-wrap owns execution.
git-workflow owns Git close-out.
```
