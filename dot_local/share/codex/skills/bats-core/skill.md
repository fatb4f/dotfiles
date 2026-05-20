---
name: bats-core
description: "Use for Bats test generation and maintenance for shell CLIs and Bashly-generated command behavior."
compatibility: "Repo-local skill for Bats core, bats-support, bats-assert, and bats-file based shell test suites."
metadata:
  version: "2.0"
  owns:
    - Bats CLI behavior tests
    - black-box executable contracts
    - argv/status/stdout/stderr assertions
  delegates:
    - Bashly source/config workflow to bashly
    - shell validation to shell-validation
---

# Bats core

Use this skill for black-box CLI behavior tests.

Prefer Bats when the tested surface is a command, generated Bashly executable, usage text, argument parser, exit code, stdout/stderr contract, or filesystem behavior.

Bats is deferred in the root workflow unless the task explicitly activates tests or existing tests are present and required by local policy.
