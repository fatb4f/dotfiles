# Bashly workflow

## Project discovery

A Bashly project root may contain one or more of:

- `bashly.yml`
- `src/bashly.yml`
- `bashly-settings.yml`
- `settings.yml`

Before editing, resolve:

```txt
project_root:
settings_file:
source_dir:
config_path:
target_dir:
generated_outputs:
test_dirs:
```

Run `scripts/inspect-project.py <project-root>` when a deterministic summary is useful.

## Source-first implementation

1. Inspect settings before assuming paths.
2. Inspect existing `bashly.yml` and tests.
3. Change YAML/config only when the CLI contract changes.
4. Change source partials/helpers for behavior.
5. Add or update tests in the same slice.
6. Regenerate.
7. Validate.
8. Inspect diff.

## YAML contract

Preserve or intentionally update:

- command names and aliases
- help text and examples
- required args
- flags and environment variables
- default values
- exit behavior documented by tests/examples
- generated command structure

Prefer schema, CUE, or `yq` validation when available.
