---
name: tree-sitter
description: "Use tree-sitter-cli as optional structural inspection evidence for Bash source."
compatibility: "Reference skill for structural source inspection with tree-sitter-cli."
metadata:
  version: "1.0"
  owns:
    - structural source inspection evidence
  delegates:
    - source edits to the active agent workflow
---

# tree-sitter

Use this skill when structural source inspection is useful for Bash source edits.

tree-sitter-cli is optional evidence. It does not replace the local CI gate.
