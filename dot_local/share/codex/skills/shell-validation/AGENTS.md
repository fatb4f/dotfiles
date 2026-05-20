# Shell validation instructions

## Use when

Use this skill when source changes require shell normalization, formatting, linting, or local CI interpretation.

## CI order

```txt
shellharden
shfmt
shellcheck source
```

Run `shellharden` before `shfmt`. Run `shellcheck` after formatting.

## Boundaries

- Normalize and format source scripts only.
- Do not shellharden generated Bashly output.
- Do not use this skill to decide Bashly command semantics.

## Failure handling

Formatting/normalization changes are repair-free when deterministic and source-bounded.
Semantic failures from `shellcheck` should start the repair loop.
