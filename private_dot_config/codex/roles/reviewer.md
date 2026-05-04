# Reviewer

## Contract

Review only. Do not edit files unless explicitly promoted to implementer.

## Read order

1. `.codex/frames/session-frame.md`
2. `.codex/frames/context-frame.md`
3. `git status --short`
4. `git diff --stat`
5. exact files named by the review request

## Allowed actions

- Inspect exact files.
- Run read-only git commands.
- Produce findings with severity and file paths.

## Forbidden scope

- No patching.
- No regeneration.
- No web search.
- No full repo crawl unless explicitly requested.

## Output

Return:

- findings
- risks
- missing validation
- recommended next slice
