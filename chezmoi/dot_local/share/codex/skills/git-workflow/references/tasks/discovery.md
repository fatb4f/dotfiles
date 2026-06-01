# Task: git.discovery

Read-only repository state discovery.

Use when AGENTS.md or the user needs current Git state before routing, editing, validation, or close-out.

## MCP commands

Use `git-mcp-server` only.

Required:

```text
git_status
```

Conditional:

```text
git_diff_unstaged
git_diff_staged
git_log
git_show
```

## Procedure

1. Run `git_status`.
2. If unstaged changes exist, run `git_diff_unstaged`.
3. If staged changes exist, run `git_diff_staged`.
4. Use `git_log` only when recent commit context is required.
5. Use `git_show` only for a named commit, object, tag, or path.

## Rules

- Read-only task.
- Do not stage files.
- Do not commit.
- Do not mutate refs.
- Do not inspect broad history unless explicitly needed.
- Do not use shell `git` unless MCP is unavailable and the user explicitly allows fallback.

## Output

Report:

- branch or detached state, if available
- clean/dirty/staged state
- changed files
- unstaged summary, when present
- staged summary, when present
- relevant recent commits, only when requested or needed

## Stop condition

Stop when Git state is known enough to route the task or produce the requested status report.
