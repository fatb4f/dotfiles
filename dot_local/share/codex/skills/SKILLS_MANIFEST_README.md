# Skill reference manifest patch

This archive adds a root `skills.cue` manifest and per-skill `skills/<id>/skill.cue` files.

## Contract

- `skills.cue` is the global skill/reference registry.
- `skills/<id>/skill.cue` is the local skill projection contract.
- `references.upstream.include` lists upstream GitHub/docs paths to validate/fetch/distill.
- `references.projected.include` lists curated local paths intended to be projected into runtime skill references.
- Full upstream source trees should not be vendored into checked-in `references/`.

## Scope

Included canonical user skills:

- agent-sdk
- argc
- bash-ast
- bashly
- bats-core
- cue
- repo-search
- sem
- shell-validation
- shellspec
- tree-sitter

Excluded from runtime projection v0:

- skills/.system/*

## Notes

The generated manifest records upstream repo/docs anchors and candidate include paths. Container DNS did not allow direct `git ls-remote` or `git ls-tree` validation, so path-level validation should be performed by an agentctl/script pass using GitHub access.
