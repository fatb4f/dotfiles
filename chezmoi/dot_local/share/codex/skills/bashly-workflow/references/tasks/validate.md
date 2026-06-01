# Task: bashly.validate

Validate shell source and Bashly project state.

Use after Bashly edits or before generation/close-out.

## Commands

Default order:

```sh
shellharden --check <source-file>
shfmt -d <source-file>
shellcheck <source-file>
bashly generate
```

Use only commands relevant to the changed files.

## Procedure

1. Identify changed Bashly source/config files.
2. Run `shellharden --check` for shell source files when applicable.
3. Run `shfmt -d` for shell source files when applicable.
4. Run `shellcheck` for shell source files when applicable.
5. Run `bashly generate` when config/source changes affect generated output.
6. Report failures without attempting unrelated repairs.

## Rules

- Prefer source-file validation before generation.
- Do not validate the entire repo by default.
- Do not rewrite files unless the task explicitly asks for formatting/fixes.
- Do not hide validation failures.
- Do not stage or commit.

## Output

Report:

- validation commands run
- pass/fail status
- failing files or checks
- whether generation is still needed
- whether close-out is blocked

## Stop condition

Stop when the relevant validation result is known.
