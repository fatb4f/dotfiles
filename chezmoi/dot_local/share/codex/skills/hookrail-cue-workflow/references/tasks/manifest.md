# Task: hookrail-cue.manifest

Edit manifest or closeout packet schemas.

## Common files

```text
cue.mods/hookrail/manifest.cue
cue.mods/hookrail/closeout.cue
cue.mods/hookrail/projection.cue
cue.mods/hookrail/fixtures/*.json
```

## Commands

Before edit:

```sh
rg "Manifest|CloseoutPacket|CaptureDecision|FailureManifest|schema:" cue.mods/hookrail
```

After edit:

```sh
cue fmt cue.mods/hookrail
cue vet cue.mods/hookrail
```

## Procedure

1. Identify the manifest/packet schema being changed.
2. Edit the schema file.
3. Edit projection only if emitted fields change.
4. Update fixtures only when expected output changes.
5. Run `cue fmt`.
6. Run `cue vet`.

## Rules

- Manifests and closeout packets are runtime evidence.
- Do not convert runtime evidence into injected repo memory.
- Do not edit shell adapter behavior here.
- Do not stage or commit.

## Output

Report only:

- schema changed
- files changed
- fixture impact
- validation result
- blocker, if any

## Stop condition

Stop after validation or blocker report.
