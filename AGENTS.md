# Repository Local Agent Guide

This repository is a dotfiles and shell-automation workspace. Follow the system
and developer instructions first; this file narrows them to this tree.

## Tree Shape

- `chezmoi/`: the managed dotfiles tree rendered into the home directory.
- `shell-wrap/`: shell and Bashly utilities for session, lockout, and hookrail
  workflows.
- `cue.mods/`: CUE policy, fixtures, and generated schema for hookrail.

## Working Rules

- Use `rg` and `rg --files` for search and inventory work.
- Use `apply_patch` for manual edits.
- Do not revert, rewrite, or discard user changes you did not make.
- Inspect `git status` and the relevant diff before making changes.
- Keep edits task-scoped; avoid touching generated or rollback artifacts unless
  they are part of the requested change.

## Change Strategy

- Prefer the smallest change that solves the task.
- Read the surrounding README or module files before editing a subsystem.
- Preserve the repository's existing conventions in shell scripts, CUE files,
  and chezmoi templates.

## Hookrail Notes

- The active adapter lives under `shell-wrap/src/hookrail`.
- CUE policy and generated fixtures live under `cue.mods/hookrail`.
- Codex hook wiring lives under
  `chezmoi/dot_local/share/codex/tools/hookrail/config/hookrail.config.toml`.
- Hookrail smoke checks are documented in
  `chezmoi/dot_local/share/codex/tools/hookrail/README.md`.

## Validation

- Run the most targeted validation available for the files you change.
- For shell and hookrail changes, prefer the existing shell tests or the
  documented smoke commands.
- For documentation-only changes, at minimum verify the staged diff is clean
  and formatted as intended.

## Completion Policy

Preferred closeout workflow:

1. Inspect repository status with Git MCP:

   git-mcp-server.git_status({
     "repo_path": "/home/_404/src/dotfiles"
   })

2. Inspect unstaged changes with Git MCP:

   git-mcp-server.git_diff_unstaged({
     "repo_path": "/home/_404/src/dotfiles"
   })

3. Inspect staged changes with Git MCP:

   git-mcp-server.git_diff_staged({
     "repo_path": "/home/_404/src/dotfiles"
   })

4. Stage only intentional task-scoped files with Git MCP:

   git-mcp-server.git_add({
     "repo_path": "/home/_404/src/dotfiles",
     "files": "AGENTS.md"
   })

   For multiple files:

   git-mcp-server.git_add({
     "repo_path": "/home/_404/src/dotfiles",
     "files": "AGENTS.md,AGENTS.transcript.md"
   })

5. Verify the staged diff with Git MCP:

   git-mcp-server.git_diff_staged({
     "repo_path": "/home/_404/src/dotfiles"
   })

6. Commit with a generated Conventional Commit message using Git MCP:

   git-mcp-server.git_commit({
     "repo_path": "/home/_404/src/dotfiles",
     "message": "docs: add repo-local agent guide"
   })

7. Inspect final repository status with Git MCP:

   git-mcp-server.git_status({
     "repo_path": "/home/_404/src/dotfiles"
   })

8. Use read-only shell Git only if needed to report the final commit SHA:

   git rev-parse --short HEAD

Report:

commit SHA
files committed
validation performed
final working tree state
