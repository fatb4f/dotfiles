---
name: bash-ast
description: "Use bash-ast or ast-bash as optional Bash parse and semantic evidence."
compatibility: "Reference skill for Bash parse proof and semantic inspection."
metadata:
  version: "1.0"
  owns:
    - Bash parse evidence
    - semantic source inspection
  delegates:
    - source edits to the active agent workflow
---

# bash-ast

Use this skill when Bash source edits need parse-level evidence beyond ordinary shell linting.

bash-ast is evidence, not mutation authority. Do not pass wholesale AST dumps into reports unless explicitly needed.
