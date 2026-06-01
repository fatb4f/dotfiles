# Task: hookrail-cue.discovery

Inspect CUE module/file layout.

## Commands

```sh
pwd
fd . cue.mods/hookrail
rg --files cue.mods/hookrail
```

Conditional:

```sh
rg "package hookrail|#Hook|#.*Manifest|#.*Feed|#.*Output|#.*Closeout|#.*Projection" cue.mods/hookrail
```

## Procedure

1. Confirm worktree location when needed.
2. Locate CUE module root.
3. List CUE source files and fixtures.
4. Identify the smallest relevant CUE surface.
5. Select the next task.

## Rules

- Read-only task.
- Do not edit files.
- Do not validate the whole module unless requested.
- Do not inspect shell-wrap unless the task explicitly crosses domains.

## Output

Report only:

- CUE module root
- relevant files
- selected task
- blocker, if any

## Stop condition

Stop when the relevant CUE surface is known.
