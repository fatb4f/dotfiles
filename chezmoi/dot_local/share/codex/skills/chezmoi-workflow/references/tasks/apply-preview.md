# Task: chezmoi.apply-preview

Preview what apply/materialization would change.

Use when the user asks what `chezmoi apply` would do, or when apply safety must be evaluated.

## Commands

Required:

```sh
chezmoi status
chezmoi diff
```

Conditional:

```sh
chezmoi doctor
chezmoi data
```

## Procedure

1. Run `chezmoi status`.
2. Run `chezmoi diff` for the requested path or bounded scope.
3. Identify the file set that would change.
4. Determine whether the diff is task-scoped.
5. Classify apply safety as one of:
   - safe-bounded
   - unsafe-unrelated
   - ambiguous
   - no-op

## Rules

- Preview only.
- Do not run `chezmoi apply`.
- Do not approve apply if the diff includes unrelated or unexplained changes.
- Do not collapse source and rendered state into one surface.
- Do not expose sensitive template data.

## Output

Report:

- files that would change
- source/rendered relationship
- unrelated drift, if any
- apply safety classification
- recommended next bounded action, if needed

## Stop condition

Stop after apply effect and safety are classified.
