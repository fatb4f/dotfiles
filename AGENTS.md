# Repository Local Agent Guide

This repository is a dotfiles and shell-automation workspace. Follow the system
and developer instructions first; this file narrows them to this tree.

## Tree Shape

- `chezmoi/`: the managed dotfiles tree rendered into the home directory.
- `shell-wrap/`: shell and Bashly utilities for session, lockout, and hookrail
  workflows.
- `cue.mods/`: CUE policy, fixtures, and generated schema for hookrail.
- `chezmoi/dot_local/share/codex/`: Codex config, hooks, skills, and tool
  payloads. A subtree-local `AGENTS.md` here overrides this file for that area.

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

When a change task modifies the repository and the user has not opted out of
commits:

- inspect status and diffs
- stage only intentional task-scoped files
- verify the staged diff
- run relevant validation when available
- commit with a generated Conventional Commit message
- report the commit SHA and validation evidence

Do not print the final task summary before git closeout is complete.
