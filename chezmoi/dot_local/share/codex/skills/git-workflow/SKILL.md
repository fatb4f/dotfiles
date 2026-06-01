---

name: git-workflow
description: "Thin task index for Git discovery and close-out using git-mcp-server."
when_to_use: Use when AGENTS.md or the user references git.discovery or git.closeout. Do not use for broad Git workflows unless one of these task names applies.
allowed-tools:
  - "MCP(git-mcp-server:*)"
  - Read

---

# Git Workflow Skill

This skill is a thin task index for repo-local Git discovery and close-out.

All Git read/write operations must go through `git-mcp-server`.

Do not use shell `git`.


## Core rules

1. Use `git-mcp-server` for Git status, diffs, staging, commits, and final state checks.
2. Stage only intentional task-scoped paths.
3. Verify staged diffs before committing.
4. Do not claim verification without observed tool output.
5. Do not expand into branch, PR, release, rebase, stash, or worktree workflows from this skill.
6. Keep close-out atomic and bounded.

## Tasks

| Task            | Use for                                           | Procedure                       |
| --------------- | ------------------------------------------------- | ------------------------------- |
| `git.discovery` | Read-only repository state discovery              | `references/tasks/discovery.md` |
| `git.closeout`  | Task-scoped staging, commit, and final Git report | `references/tasks/closeout.md`  |

## Cross-skill boundary

Use this skill for Git state.

Use `chezmoi-workflow` for chezmoi source/rendered state.

During repo close-out:

```text id="rvdn78"
1. Run git.discovery.
2. Run chezmoi.closeout when chezmoi-managed files may be involved.
3. Run git.closeout only when commit-before-summary is explicitly requested.
```

## Skill invariant

```text id="9bs6s1"
AGENTS.md selects git.discovery or git.closeout.
git-workflow/SKILL.md maps the task to a task reference.
references/tasks/*.md defines commands, output, and stop conditions.
git-mcp-server executes Git operations.
```
