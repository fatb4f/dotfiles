# Task: git.discovery

Read-only repository state discovery.

Use when AGENTS.md or the user needs current Git state before routing, editing, validation, or close-out.

## MCP tools

Use `git-mcp-server` only.

Shell `git` is not a fallback for this task.

Required:

```text
git-mcp-server.git_status
```

Conditional:

```text
git-mcp-server.git_diff_unstaged
git-mcp-server.git_diff_staged
git-mcp-server.git_log
git-mcp-server.git_show
```

## Procedure

1. Call `git-mcp-server.git_status`.
2. If unstaged changes exist, call `git-mcp-server.git_diff_unstaged`.
3. If staged changes exist, call `git-mcp-server.git_diff_staged`.
4. Call `git-mcp-server.git_log` only when recent commit context is required.
5. Call `git-mcp-server.git_show` only for a named commit, object, tag, or path.

## Rules

- Read-only task.
- Do not stage files.
- Do not commit.
- Do not mutate refs.
- Do not inspect broad history unless explicitly needed.
- Do not use shell `git`.
- Do not diagnose `.git` filesystem permissions.
- Git MCP output is the only authoritative Git evidence for this task.

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
