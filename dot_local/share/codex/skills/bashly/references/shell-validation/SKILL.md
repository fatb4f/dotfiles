---
name: shell-validation
description: "Use for local shell CI validation: shellharden, shfmt, shellcheck, and pre-commit formatting/lint gates."
compatibility: "Repo-local validation skill for Bash source scripts and shell test surfaces."
metadata:
  version: "2.0"
  owns:
    - shellharden normalization
    - shfmt formatting
    - shellcheck source linting
    - local CI gate interpretation
---

# Shell validation

Use this skill for shell normalization, formatting, linting, and local CI gate interpretation.

## Contract

The local CI order is:

```txt
shellharden
shfmt
shellcheck source
```

This skill validates shell source. It does not decide Bashly CLI intent.

## Pre-commit posture

Deterministic formatting and normalization may be auto-staged by a pre-commit workflow when limited to source files.

Only the validation gate decides whether the commit can proceed.

## Deferred surfaces

Generated-output linting is deferred unless explicitly activated.
Bats and ShellSpec tests are deferred unless explicitly activated.
