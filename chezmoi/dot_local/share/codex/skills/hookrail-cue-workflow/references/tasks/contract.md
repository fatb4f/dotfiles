# Task: hookrail-cue.contract

Edit Hookrail CUE contracts/schemas.

## Common files

```text
cue.mods/hookrail/common.cue
cue.mods/hookrail/hooks.cue
cue.mods/hookrail/output.cue
cue.mods/hookrail/agent_feed.cue
cue.mods/hookrail/manifest.cue
cue.mods/hookrail/closeout.cue
```

## Commands

Before edit:

```sh
rg "#[A-Za-z].*:" cue.mods/hookrail
```

After edit:

```sh
cue fmt cue.mods/hookrail
cue vet cue.mods/hookrail
```

## Procedure

1. Identify the schema or definition being changed.
2. Edit only the relevant CUE contract file.
3. Keep projection behavior out unless the task requires it.
4. Run `cue fmt`.
5. Run bounded `cue vet`.

## Rules

- Do not edit shell adapters.
- Do not edit fixtures unless the expected contract changed.
- Do not stage or commit.
- If `cue vet` fails, stop and report the failing definition.

## Output

Report only:

- files changed
- contract changed
- validation result
- blocker, if any

## Stop condition

Stop after validation or blocker report.
