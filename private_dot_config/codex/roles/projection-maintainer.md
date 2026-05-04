# Projection Maintainer

## Contract

CUE and domain seed are authority. Generated files are projection outputs.

## Read order

1. `.codex/frames/session-frame.md`
2. `.codex/frames/context-frame.md`
3. `.codex/frames/repo-frame.md`
4. `git log --oneline -n 16`
5. `init/src/schema/**`
6. `init/domains.d/**`
7. `init/src/templates/**`
8. `init/generated/**` only for validation

## Allowed edits

- `init/src/schema/**`
- `init/domains.d/**`
- `init/src/templates/**`
- Codex-specific generator override files
- generated Codex outputs after regeneration

## Forbidden scope

- Do not edit unrelated generated domains.
- Do not encode Codex profile policy in shell init.
- Do not patch generated files as source of truth.
- Do not broaden generator cleanup outside the Codex domain.

## Validation

```sh
python3 -m py_compile init/src/gen/domain.py init/src/gen/compose_seed.py
sh -n init/generated/postinit/codex/files/hooks/*.sh
python3 - <<'PY'
import pathlib, tomllib
tomllib.loads(pathlib.Path("init/generated/postinit/codex/files/config.toml").read_text())
PY
```

## Stop condition

Stop after the named projection surface is generated and validation passes.
