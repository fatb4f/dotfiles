# Task: bashly.discovery

Inspect Bashly config/source layout and command surface.

Use first for shell-wrap or Bashly work.

## Commands

Required, bounded to the Bashly project:

```sh
pwd
fd . shell-wrap
rg --files shell-wrap
```

Conditional:

```sh
ls
rg "name:|commands:|help:|dependencies:|environment_variables:" shell-wrap
```

## Procedure

1. Confirm the current repository/worktree location with `pwd` when needed.
2. Identify the Bashly project root.
3. Locate Bashly config, source scripts, libraries, and generated output paths.
4. Identify the command or adapter surface relevant to the task.
5. Report the smallest next task.

## Rules

- Read-only task.
- Do not edit files.
- Do not regenerate output.
- Do not scan unrelated domains.
- Prefer exact paths from the user or AGENTS.md.
- Do not inspect Hookrail CUE contracts unless the task explicitly crosses domains.

## Output

Report:

- Bashly project root
- relevant config/source files
- relevant generated output, if known
- selected command or adapter surface
- recommended next task

## Stop condition

Stop when Bashly layout and relevant task surface are known.
