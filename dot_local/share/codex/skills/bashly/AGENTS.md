# Bashly skill instructions

## Use when

Use this skill for Bashly source/config work, generated artifact reasoning, CLI behavior changes, and Bashly project validation.

## Workflow

1. Inspect the Bashly config and identify the source scripts involved.
2. Edit Bashly config or `src/*.sh` only when needed.
3. Treat generated Bashly output as disposable evidence.
4. Do not manually patch generated Bashly output.
5. Hand validation to the shell-validation workflow.
6. Report changed source, local CI result, and remaining failures.

## Skill handoff

- Use `shell-validation` for `shellharden -> shfmt -> shellcheck` and local CI interpretation.
- Use `argc` when argv annotations or `$argc_*` references are relevant.
- Use `bash-ast` and `tree-sitter` only as optional analysis evidence.
- Use `bats-core` or `shellspec` only when tests are explicitly in scope.
