# Task: bashly.adapter

Inspect executable Hookrail adapter behavior.

Use when shell-wrap work involves Hookrail executable adapters, command dispatch, or runtime adapter behavior.

## Commands

Discovery:

```sh
rg "hookrail|codex|closeout|manifest|trace|feed|project" shell-wrap
rg --files shell-wrap
```

Conditional validation:

```sh
shellharden --check <source-file>
shfmt -d <source-file>
shellcheck <source-file>
bashly generate
```

## Procedure

1. Identify the executable adapter entrypoint.
2. Identify the Bashly command/action that owns the behavior.
3. Inspect source/config only.
4. Keep CUE contract/feed/projection semantics out of this task.
5. Validate source changes if edits are made.
6. Generate only when Bashly source/config changes require it.

## Rules

- This task owns shell execution behavior only.
- Do not change Hookrail CUE contracts.
- Do not change feed/projection schema here.
- Do not manually patch generated shell output.
- Do not stage or commit.

## Output

Report:

- adapter entrypoint
- Bashly command/action files
- behavior inspected or changed
- validation/generation evidence
- whether CUE-side work is required as a separate task

## Stop condition

Stop when executable adapter behavior is understood or the shell-side change is validated.
