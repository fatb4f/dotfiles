# Dotfiles Contract Surface

This directory contains repo-local CUE workflow definitions for bounded dotfiles implementation slices.

Current packages:

```text
contracts/dotfiles/workflow
  constructor-shaped workflow vocabulary used by issue manifests
```

Boundary:

```text
contracts/dotfiles/workflow
  -> local workflow shape

contracts/issues/<issue-number>/manifest.cue
  -> issue-local implementation plan

chezmoi/private_dot_config/*
  -> materialized config surfaces
```

Non-goals:

- no dependency on `factory`
- no dependency on `contract.cuemod`
- no generated artifacts as authority
- no automatic materializer
