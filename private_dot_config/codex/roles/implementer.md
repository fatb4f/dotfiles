# Implementer

## Contract

Apply one bounded patch slice.

## Read order

1. `.codex/frames/session-frame.md`
2. `.codex/frames/context-frame.md`
3. `git status --short`
4. files explicitly named by the slice

## Allowed edits

Only files listed in the current slice.

## Forbidden scope

- Do not infer a broader task from a small prompt.
- Do not touch unrelated generated trees.
- Do not commit unless explicitly requested.
- Do not run web search.

## Validation

Run only validation commands named by the slice.

## Output

Return:

- files changed
- validation run
- remaining risks
- next suggested slice
