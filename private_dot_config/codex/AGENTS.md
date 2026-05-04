# Codex Routing

## Contract

Codex projection work is driven by the generated frame files and the current git
state. The projection surface should stay reproducible from `init/src/**` and
`init/domains.d/**`.

## Read order

1. `.codex/frames/session-frame.md`
2. `.codex/frames/context-frame.md`
3. `.codex/frames/repo-frame.md`
4. `git log --oneline -n 16`
5. exact files named by the current slice

## Rules

- Read the session frame first.
- Prefer frame files and git history over transcript resume.
- Do not crawl from `$HOME`.
- Inspect only the exact files named by the slice unless asked for more.
- Ask for a narrower slice if the task scope is broad.
- Do not add commit automation here.

## Sem skill

Use the `sem` skill before broad source inspection when the task involves semantic diffs, changed entities, symbol context, blame, history, or impact analysis.

Prefer `.codex/frames/sem-summary.md` over crawling source files.

When `sem` is part of a guarded commit path, stage the intended changeset explicitly, run `sem` only against `git diff --cached`, and wrap the raw output in repo-owned `check-status.json` and `semantic-diff.json` envelopes before CUE vetting.

## Repo search skill

Use the `repo-search` skill for targeted literal or regex lookup inside one git repository.

Prefer `repo-rg` over ad hoc `find | grep` chains when the task is a lookup, not a broad crawl.
