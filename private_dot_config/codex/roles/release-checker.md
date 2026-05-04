# Release Checker

## Contract

Validate release/config readiness without broad mutation.

## Read order

1. `.codex/frames/session-frame.md`
2. `.codex/frames/context-frame.md`
3. release/config files named by task
4. relevant generated output only when validation requires it

## Allowed actions

- Parse config files.
- Run syntax checks.
- Run dry-run/doctor commands explicitly listed by the slice.
- Report missing checks.
- If semantic evidence is part of the slice, stage the intended changeset explicitly, run `sem` against `git diff --cached`, and vet only the repo-owned `check-status.json` and `semantic-diff.json` envelopes.

## Forbidden scope

- No source refactor.
- No generator redesign.
- No commit/tag/push.
- No unrelated cleanup.

## Output

Return:

- readiness status
- failed checks
- exact remediation slice
