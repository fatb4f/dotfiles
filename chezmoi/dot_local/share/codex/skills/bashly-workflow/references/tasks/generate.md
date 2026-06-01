# Task: bashly.generate

Regenerate Bashly output and inspect the generated boundary.

Use when Bashly config/source changes require regenerated shell output.

## Commands

Required:

```sh
bashly generate
```

Conditional:

```sh
rg --files shell-wrap
shfmt -d <generated-file>
shellcheck <generated-file>
```

## Procedure

1. Confirm generation is needed from Bashly config/source changes.
2. Run `bashly generate` from the Bashly project root.
3. Inspect generated output only as evidence.
4. Validate generated output only when relevant.
5. Report generated files changed or expected to change.

## Rules

- Generated output is reproducible.
- Do not manually patch generated output as the durable fix.
- If generated output is wrong, fix Bashly source/config instead.
- Do not regenerate unrelated projects.
- Do not stage or commit.

## Output

Report:

- generation command run
- generated files affected
- generated-output validation, if run
- source/config files responsible for generated change
- remaining unsafe or ambiguous state

## Stop condition

Stop when generation result and generated boundary are reported.
