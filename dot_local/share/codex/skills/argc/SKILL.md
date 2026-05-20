---
name: argc
description: "Use for argc annotation and argv-context guidance inside Bash source scripts."
compatibility: "Reference skill for argc annotations and local argv context in Bash projects."
metadata:
  version: "1.0"
  owns:
    - argc annotation context
    - local argv reference interpretation
  delegates:
    - public CLI authority to bashly
---

# argc

Use this skill when Bash source uses argc annotations or `$argc_*` variables.

argc provides local argv context. It does not override Bashly's public CLI authority.

Use argc for `@cmd`, `@arg`, `@option`, `@flag`, `@env`, `$argc_name`, and `${argc_name}` interpretation.
