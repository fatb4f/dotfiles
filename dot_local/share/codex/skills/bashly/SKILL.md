---
name: bashly
description: "Use for Bashly source-edit workflow work: Bashly config/source inspection, generated artifact boundaries, local CI validation, and CLI behavior reasoning."
compatibility: "Designed for Bashly repositories with local source scripts, generated Bashly output, and shell validation tooling."
metadata:
  version: "2.0"
  repo: "fatb4f/bashly.sh"
  owns:
    - Bashly config/source workflow
    - generated artifact boundary
    - source edit contract
  delegates:
    - shell normalization and linting to shell-validation
    - Bats behavior tests to bats-core
    - ShellSpec source-level tests to shellspec
    - argc annotation context to argc
    - Bash parse evidence to bash-ast
    - structural inspection evidence to tree-sitter
---

# Bashly source-edit workflow

Use this skill when work involves Bashly configuration, Bashly source scripts, generated CLI behavior, or validation of a Bashly project.

## Contract

Bashly source editing means:

```txt
inspect Bashly config and source
edit source/config only when needed
run local CI
report remaining failures
```

Generated Bashly output is reproducible. Inspect and execute it as evidence, but do not manually patch it as the durable fix.

## Authority order

1. Bashly settings and config
2. `src/*.sh` Bash source scripts
3. tests and examples
4. generated output as evidence only
5. docs

## Validation authority

The local pre-commit/CI workflow is the validation authority.

Current required order:

```txt
shellharden
shfmt
shellcheck source
bashly generate
CI report
```

Generated-output linting and Bats/ShellSpec tests are deferred unless the task explicitly activates them.

## Completion report

Report:

```txt
skill_context:
project_root:
changed_source:
local_ci:
remaining_failures:
```
