# Task: chezmoi.closeout

Produce chezmoi status/diff handoff for repo close-out.

Use after discovery, drift/edit/materialization/apply-preview work, or when root AGENTS.md requests repo-level close-out.

This task is observation and handoff only.

Git staging and commits are handled by `git-workflow`.

## Commands

Required:

```sh
chezmoi status
chezmoi diff
```

Conditional:

```sh
chezmoi managed
chezmoi source-path
chezmoi target-path
chezmoi doctor
```

## Procedure

1. Run `chezmoi status`.
2. Run `chezmoi diff` for changed or task-relevant paths.
3. Identify source/rendered drift.
4. Identify whether drift is task-scoped.
5. Classify apply state as one of:
   - no-op
   - apply-pending-safe
   - apply-pending-ambiguous
   - apply-unsafe-unrelated
6. Report whether Git close-out can proceed.
7. Hand Git commit work back to `git-workflow`.

## Rules

- Do not run `chezmoi apply`.
- Do not stage files.
- Do not commit.
- Do not edit files.
- Do not inspect unrelated domains.
- Do not hide drift; classify it.
- Do not claim apply safety without observed `chezmoi diff` output.

## Output

Report:

- chezmoi status summary
- drifted paths
- source/rendered relationship
- apply state
- unsafe or unrelated drift
- whether Git close-out can proceed
- any remaining unknown state

## Stop condition

Stop when chezmoi state is summarized for handoff to root AGENTS.md or `git-workflow`.
