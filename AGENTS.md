# Repository Local Agent Guide

This repository is a dotfiles and shell-automation workspace. System and
developer instructions take precedence; this file only records repo-local
structure and closeout expectations.

## Tree

- `chezmoi/`: managed dotfiles rendered into the home directory.
- `shell-wrap/`: shell and Bashly utilities for session, lockout, and hookrail.
- `cue.mods/`: CUE policy, fixtures, and generated schema for hookrail.
- Hookrail implementation and wiring live under `shell-wrap/src/hookrail` and
  `chezmoi/dot_local/share/codex/tools/hookrail/`.

## Working Rules

- Use `rg` and `rg --files` for search and inventory work.
- Use `apply_patch` for manual edits.
- Do not revert, rewrite, or discard user changes you did not make.
- Check `git status` and the relevant diff before making changes.
- Keep edits task-scoped and avoid generated or rollback artifacts unless they
  are part of the request.
- Read the surrounding README or module files before changing a subsystem.

## Validation

- Run the smallest useful validation for the files you change.
- For shell and hookrail changes, prefer the existing shell tests or documented
  smoke commands.
- For docs-only changes, verify the staged diff is clean and formatted as
  intended.

## Closeout

When a task changes the repo and the user has not opted out of commits:

1. Inspect status and unstaged/staged diffs.
2. Stage only task-scoped files.
3. Verify the staged diff.
4. Run targeted validation.
5. Commit with a Conventional Commit message.
6. Report the commit SHA, files committed, validation evidence, and final
   working tree state.
