---
name: git-workflow
description: "Use for Git status/diff/commit/branch/PR/release tasks, merge gates, hook setup, and git-worktree debugging."
when_to_use: Use for Git status/diff/commit/branch/PR/release tasks, merge gates, hook setup, and write-protected .git/index/refs failures. Do not use for non-Git filesystem edits unless they are part of a Git workflow.
license: "(MIT AND CC-BY-SA-4.0). See LICENSE-MIT and LICENSE-CC-BY-SA-4.0"
compatibility: "Requires git-mcp-server and gh CLI."
metadata:
  author: Netresearch DTT GmbH
  version: "1.14.0"
  repository: https://github.com/netresearch/git-workflow-skill
allowed-tools:
  - Bash(gh:*)
  - MCP(git-mcp-server:*)
  - Read
  - Write
---

# Git Workflow Skill

Use this skill for Git work that needs repo-aware status, staging, commits, PRs, merges, releases, or hook handling.
All Git read/write operations in this skill must go through `git-mcp-server`.

## Rules

1. Use `git-mcp-server` tools for all Git reads and writes. Do not fall back to shell `git`.
2. Stage only intentional paths.
3. Do not claim verification without pasted command output.
4. Force-push only with `--force-with-lease`.
5. Never edit installed skill/plugin cache paths; stay in the repo worktree and verify `pwd` first.
6. Keep commit history atomic unless the user asks otherwise.

See `references/pull-request-workflow.md` for merge gates and review-thread handling.

## Reference Files

Load the matching reference only when the task needs it:

| Reference | Content Triggers |
|-----------|-----------------|
| `references/branching-strategies.md` | Branching models and branch protection |
| `references/commit-conventions.md` | Commit messages, atomic commits, commit templates |
| `references/pull-request-workflow.md` | PR create/review/merge, merge gates, thread resolution |
| `references/ci-cd-integration.md` | GitHub Actions, GitLab CI, semantic release, deployment |
| `references/advanced-git.md` | Rebase, cherry-pick, bisect, stash, worktrees, reflog, submodules, recovery |
| `references/github-releases.md` | Release management and immutable releases |
| `references/git-hooks-setup.md` | Hook frameworks, detection, and installation |
| `references/claude-code-hooks.md` | Claude Code `settings.json` hooks |
| `references/code-quality-tools.md` | shellcheck, shfmt, git-absorb, difftastic |

## Local Git Write Workflow

1. Use `git-mcp-server` tools for Git discovery, status, diffs, staging, commits, and history. Use `tool_search` only if you need to confirm the available tool names.
2. Use read-only commands or MCP status/diff tools to inspect the repository:
   `git_status`, `git_diff_unstaged`, `git_diff_staged`, `git_log`, `git_show`.
3. Stage only intentional paths with MCP `git_add`; never stage generated or unrelated files by accident.
4. Verify the staged diff with MCP `git_diff_staged` before committing.
5. Commit with MCP `git_commit` and a Conventional Commit message.
6. Check final state with MCP `git_status`.

Use shell `git` writes only when no Git MCP write tool is available or the user explicitly asks for shell Git. If `.git` is write-protected from the shell but Git MCP is configured, do not report blocked until the MCP write path has been attempted.

## Git Closeout

Use this when Hookrail, AGENTS.md, or the user requests commit-before-summary closeout:

1. Inspect repository status.
2. Inspect unstaged and staged diffs.
3. Stage only task-scoped files.
4. Verify the staged diff.
5. Commit with a Conventional Commit message.
6. Check final status.
7. Report commit SHA, staged files, and validation evidence.

---

> **Contributing:** https://github.com/netresearch/git-workflow-skill
