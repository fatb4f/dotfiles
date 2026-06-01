# Task: chezmoi.discovery

Read-only chezmoi state discovery.

Use first for chezmoi dotfile lifecycle work.

## Commands

Required:

```sh
chezmoi status
```

Conditional:

```sh
chezmoi diff
chezmoi managed
chezmoi source-path
chezmoi target-path
chezmoi doctor
```

## Procedure

1. Run `chezmoi status`.
2. If the task names a path, check whether it is managed with `chezmoi managed`.
3. Map source and target paths with `chezmoi source-path` and `chezmoi target-path` only when needed.
4. Run `chezmoi diff` only when status shows drift or the user asks for diff.
5. Run `chezmoi doctor` only when the task indicates configuration or runtime uncertainty.

## Rules

- Read-only task.
- Do not edit files.
- Do not run `chezmoi apply`.
- Do not inspect all managed files unless requested.
- Prefer exact paths from the user or AGENTS.md.

## Output

Report:

- chezmoi status summary
- relevant managed paths
- source path, when mapped
- target path, when mapped
- whether drift exists
- unknown or unsafe state

## Stop condition

Stop when chezmoi state is known enough to route the next task.
