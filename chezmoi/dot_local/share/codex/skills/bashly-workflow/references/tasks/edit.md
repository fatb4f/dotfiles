# Task: bashly.edit

Edit Bashly config or source scripts.

Use after `bashly.discovery`.

## Commands

Before edit:

```sh
rg --files shell-wrap
```

After edit, choose the smallest relevant validation:

```sh
shellharden --check <file>
shfmt -d <file>
shellcheck <file>
```

Conditional:

```sh
bashly generate
```

## Procedure

1. Identify the authoritative Bashly config/source file.
2. Edit only Bashly config or source scripts.
3. Do not patch generated shell output as the durable fix.
4. Run the smallest relevant source validation.
5. If command shape changed, run `bashly.generate`.

## Rules

- Edit source/config only.
- Do not edit generated output unless the task is explicitly diagnostic and the change is not kept.
- Keep edits task-scoped.
- Do not change Hookrail CUE contracts from this task.
- Do not stage or commit.

## Output

Report:

- source/config files edited
- generated output affected, if known
- validation commands run
- generation status, if generated
- remaining unknown or unsafe state

## Stop condition

Stop after source edit and validation/generation report.
