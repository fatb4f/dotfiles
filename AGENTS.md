# AGENTS.md

## Required Workflow

Before repository work:

1. Load `.codex/skills/SKILL.md`.
2. Load `workspace.cue`.
3. Load `.codex/workflow.cue`.
4. Select the smallest matching workspace domain.
5. Run validation through:

```sh
cue cmd validate ./.codex
```

## Closeout

Before final response after any repository mutation:

1. Run `cue cmd validate ./.codex`.
2. Run `git status --short`.
3. Stage intentional changes.
4. Commit with a scoped message.
5. Push when the branch has an upstream.
6. Report validation, changed files, commit SHA, and push result.

Do not treat a task as complete while the worktree contains unstaged or
uncommitted intentional changes.
