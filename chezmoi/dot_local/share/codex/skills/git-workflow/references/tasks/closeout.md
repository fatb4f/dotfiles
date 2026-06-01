# Task: git.closeout

Task-scoped Git staging, commit, and final Git report.

Use only when AGENTS.md or the user explicitly requests Git close-out, commit-before-summary, or final commit handoff.

## MCP commands

Use `git-mcp-server` only.

Required:

```text
git-mcp-server.git_status
git-mcp-server.git_diff_unstaged
git-mcp-server.git_diff_staged
git-mcp-server.git_add
git-mcp-server.git_commit
git-mcp-server.git_status
```

Conditional:

```text
git_log
git_show
```

## Procedure

1. Call `git-mcp-server.git_status`.
2. Call `git-mcp-server.git_diff_unstaged`.
3. Call `git-mcp-server.git_diff_staged`.
4. Identify the task-scoped file set.
5. Stage only task-scoped files with `git-mcp-server.git_add`.
6. Re-run `git-mcp-server.git_diff_staged`.
7. Verify the staged diff contains only intentional changes.
8. Commit with `git-mcp-server.git_commit`.
9. Run final `git-mcp-server.git_status`.

## Failure rule

Do not report Git close-out blocked until:

1. `git-mcp-server.git_status` has run.
2. `git-mcp-server.git_diff_unstaged` has run.
3. `git-mcp-server.git_diff_staged` has run.
4. `git-mcp-server.git_add` has been attempted when staging is needed.
5. `git-mcp-server.git_commit` has been attempted.

Shell Git failure is not authoritative.
Filesystem permission diagnosis is not part of this task.

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
