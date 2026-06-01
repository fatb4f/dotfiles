# Task: git.closeout

Task-scoped Git staging, commit, and final Git report.

Use only when AGENTS.md or the user explicitly requests Git close-out, commit-before-summary, or final commit handoff.

## MCP commands

Use `git-mcp-server` only.

Required:

```text
git_status
git_diff_unstaged
git_diff_staged
git_add
git_commit
git_status
```

Conditional:

```text
git_log
git_show
```

## Procedure

1. Run `git_status`.
2. Run `git_diff_unstaged`.
3. Run `git_diff_staged`.
4. Identify the task-scoped file set.
5. Stage only task-scoped files with `git_add`.
6. Re-run `git_diff_staged`.
7. Verify the staged diff contains only intentional changes.
8. Commit with `git_commit`.
9. Run final `git_status`.

## Commit message

Use a Conventional Commit message.

Preferred scopes:

```text
agents
git-workflow
chezmoi-workflow
chezmoi
hookrail
shell-wrap
docs
```

Examples:

```text
docs(agents): route git closeout through skill task
refactor(git-workflow): split closeout procedure into task reference
feat(chezmoi-workflow): add source rendered lifecycle tasks
```

## Rules

- Stage only intentional task-scoped files.
- Do not stage broad directories by default.
- Do not stage unrelated dirty files.
- Do not commit generated files unless the task explicitly includes them.
- Do not commit if the staged diff contains unrelated changes.
- Do not run PR, branch, release, stash, reset, or worktree workflows from this task.
- Do not claim verification without observed MCP output.

## Output

Report:

- commit SHA, if committed
- commit message
- staged files
- final Git status
- unstaged/uncommitted remainder, if any
- validation evidence, if provided by the task

## Blockers

Block close-out when:

- dirty files are unrelated to the task
- staged diff is ambiguous
- validation is required but missing
- commit permission is unclear
- user requested observation-only close-out

## Stop condition

Stop when a commit is created and final status is reported, or when a blocker is reported.
