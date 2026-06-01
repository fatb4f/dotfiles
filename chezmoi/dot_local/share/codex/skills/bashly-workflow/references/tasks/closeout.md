# Task: bashly.closeout

Produce shell-wrap status/validation handoff for repo close-out.

Use after Bashly source/config, generated boundary, or executable adapter work.

This task is observation and handoff only.

Git staging and commits are handled by `git-workflow`.

## Commands

Use only commands relevant to changed shell-wrap files.

Status/discovery:

```sh
rg --files shell-wrap
```

Validation, when applicable:

```sh
shellharden --check <source-file>
shfmt -d <source-file>
shellcheck <source-file>
bashly generate
```

## Procedure

1. Identify shell-wrap files touched by the task.
2. Identify whether changes are source/config, generated output, or both.
3. Confirm generated output was not manually patched as the durable fix.
4. Run or summarize the smallest relevant validation set.
5. Report whether Git close-out can proceed.
6. Hand Git commit work back to `git-workflow`.

## Rules

- Do not stage files.
- Do not commit.
- Do not edit files.
- Do not mutate unrelated shell-wrap surfaces.
- Do not hide validation failures.
- Do not claim generated output is current without generation evidence when generation is required.

## Output

Report:

- shell-wrap files touched
- source/config changes
- generated output changes, if any
- validation commands run
- pass/fail state
- blockers for Git close-out
- whether Git close-out can proceed

## Stop condition

Stop when shell-wrap state is summarized for handoff to root AGENTS.md or `git-workflow`.
