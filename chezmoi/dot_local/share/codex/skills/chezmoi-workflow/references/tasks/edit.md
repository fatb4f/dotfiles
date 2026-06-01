# Task: chezmoi.edit

Edit authoritative chezmoi source files.

Use after discovery and drift classification.

## Commands

Before edit:

```sh
chezmoi status
chezmoi source-path
chezmoi target-path
```

After edit:

```sh
chezmoi diff
chezmoi status
```

Conditional:

```sh
chezmoi managed
chezmoi doctor
```

## Procedure

1. Confirm the file is chezmoi-managed when a target path is provided.
2. Identify the authoritative source path with `chezmoi source-path`.
3. Identify the affected target path with `chezmoi target-path` when useful.
4. Edit only the chezmoi source file.
5. Run `chezmoi diff` to inspect the rendered effect.
6. Run `chezmoi status` to summarize remaining state.

## Rules

- Edit source files, not rendered target files.
- Do not run `chezmoi apply`.
- Do not edit unrelated dotfiles.
- Do not continue if the file is not managed by chezmoi, unless the user explicitly requests adding it to chezmoi.
- Preserve existing template conventions.

## Output

Report:

- source file edited
- target/rendered file affected, if known
- diff summary
- remaining chezmoi status
- whether apply is pending

## Stop condition

Stop after the source edit and diff/status report.
