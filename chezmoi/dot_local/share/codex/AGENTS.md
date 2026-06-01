# Global Codex Agent Policy

This file intentionally stays small.

Use system and developer instructions as the primary authority. When a
workspace contains its own `AGENTS.md`, treat that file as a repository-local
overlay for that workspace.

Use configured skills and MCP tools for task-specific operating procedures.

## Completion policy

When a coding/change task modifies the repository and the user has not explicitly opted out of commits, the agent must complete git closeout before the final summary.

Git closeout means:
- inspect status and diffs
- stage only intentional task-scoped files
- verify the staged diff
- run relevant validation when available
- commit with a generated Conventional Commit message
- report commit SHA and validation evidence

Do not print the final task summary before git closeout is complete.
