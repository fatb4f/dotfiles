# CUE Projection Skill

Use this skill when modifying dotfile projection surfaces.

## Contract

- Treat CUE as the authority plane.
- Treat shell scripts as adapters.
- Keep generated files reproducible from `init/src/**` and `init/domains.d/**`.
- Do not encode Codex profile policy in interactive or noninteractive shell init.

## Expected workflow

```txt
change schema/domain seed
-> regenerate projected files
-> parse/check generated scripts
-> run doctor/dry-run
```

## Local commands

```sh
cd init
just gen
just check-generated
just dry-run
just doctor
```
