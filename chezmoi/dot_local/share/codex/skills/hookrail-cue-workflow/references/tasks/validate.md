# Task: hookrail-cue.validate

Validate CUE changes with fixtures.

## Commands

Default:

```sh
cue fmt cue.mods/hookrail
cue vet cue.mods/hookrail
```

If a fixture is named:

```sh
cue vet cue.mods/hookrail <fixture-path>
```

Discovery:

```sh
fd . cue.mods/hookrail/fixtures
```

## Procedure

1. Run `cue fmt`.
2. Run bounded `cue vet`.
3. If a fixture is relevant, run fixture-specific vet.
4. Report failures without unrelated repairs.

## Rules

- Do not broaden validation beyond the task by default.
- Do not edit files during validation except formatting from `cue fmt`.
- Do not stage or commit.
- Do not hide incomplete CUE failures.

## Output

Report only:

- commands run
- pass/fail
- failing file/definition, if any
- blocker, if any

## Stop condition

Stop when validation result is known.
