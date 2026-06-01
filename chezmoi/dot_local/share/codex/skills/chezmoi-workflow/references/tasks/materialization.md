# Task: chezmoi.materialization

Inspect source-to-target/rendered relationship.

Use after editing or when the task asks how chezmoi source becomes target material.

## Commands

Required:

```sh
chezmoi source-path
chezmoi target-path
chezmoi diff
```

Conditional:

```sh
chezmoi status
chezmoi data
```

## Procedure

1. Identify the source path.
2. Identify the target path.
3. Inspect the rendered effect with `chezmoi diff`.
4. Use `chezmoi data` only when template variables are relevant.
5. Classify materialization as:
   - direct
   - templated
   - generated
   - ambiguous

## Rules

- Do not run `chezmoi apply`.
- Do not edit rendered output.
- Do not assume filename mapping is direct when templates or attributes are involved.
- Do not dump large or sensitive template data.

## Output

Report:

- source path
- target path
- materialization type
- relevant rendered effect
- template data dependency, if relevant
- ambiguity or unsafe state

## Stop condition

Stop when the source-to-target relationship is clear or explicitly ambiguous.
