---
name: shellspec
description: "Use for ShellSpec tests for sourceable shell functions, helper libraries, mocks, parameters, and unit-level behavior."
compatibility: "Repo-local skill for ShellSpec-based shell unit and component tests."
metadata:
  version: "2.0"
  owns:
    - ShellSpec source-level tests
    - sourceable shell function behavior
    - mocks and parameterized examples
  delegates:
    - generated CLI behavior tests to bats-core
    - shell validation to shell-validation
---

# ShellSpec

Use this skill for source-level shell tests.

Prefer ShellSpec when the target is a function, helper, source partial, normalizer, parser, or branch-heavy shell unit.

ShellSpec is deferred in the root workflow unless explicitly activated by the task or existing tests are required by local policy.
