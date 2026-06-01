# Task: chezmoi.drift

Classify source/rendered drift before change.

Use after `chezmoi.discovery` when status or user request indicates possible drift.

## Commands

Required:

```sh
chezmoi status
chezmoi diff
```

Conditional:

```sh
chezmoi managed
chezmoi source-path
chezmoi target-path
```

## Procedure

1. Run `chezmoi status`.
2. Run `chezmoi diff` for the relevant bounded scope.
3. Map source/target paths when the drift owner is unclear.
4. Classify drift as one of:
   - absent
   - expected-task-scoped
   - unexpected
   - ambiguous
   - unsafe-unrelated

## Rules

- Do not run `chezmoi apply`.
- Do not edit files.
- Do not normalize drift unless explicitly requested.
- Do not assume all drift belongs to the current task.
- Do not edit rendered targets when source files are authoritative.

## Output

Report:

- drift classification
- drifted paths
- source/rendered relationship
- whether drift is task-scoped
- whether apply would be unsafe or ambiguous

## Stop condition

Stop when drift is classified or explicitly marked ambiguous.
