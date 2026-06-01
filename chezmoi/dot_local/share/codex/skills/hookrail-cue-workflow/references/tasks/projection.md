# Task: hookrail-cue.projection

Edit projection/gating behavior.

## Common files

```text
cue.mods/hookrail/projection.cue
cue.mods/hookrail/common.cue
cue.mods/hookrail/output.cue
cue.mods/hookrail/fixtures/*.json
```

## Commands

Before edit:

```sh
rg "_closeoutRequired|_payloadClass|_agentText|_feed|frame|trace|manifest" cue.mods/hookrail/projection.cue
```

After edit:

```sh
cue fmt cue.mods/hookrail
cue vet cue.mods/hookrail
```

## Procedure

1. Identify the projection branch being changed.
2. Edit `projection.cue` or the smallest supporting contract.
3. Update fixtures only when expected behavior changes.
4. Run `cue fmt`.
5. Run `cue vet`.

## Rules

- Do not change shell execution here.
- Do not change Git close-out mechanics here.
- Do not turn traces/manifests into repo memory.
- Do not stage or commit.

## Output

Report only:

- projection branch changed
- files changed
- fixtures changed, if any
- validation result
- blocker, if any

## Stop condition

Stop after validation or blocker report.
