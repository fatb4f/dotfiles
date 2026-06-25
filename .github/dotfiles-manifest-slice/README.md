# Dotfiles Manifest Slice Bundle

This directory contains the dotfiles-local Codex/CUE implementation workflow bundle.

It is intentionally scoped under `.github` because it supports issue-driven implementation workflow rather than runtime dotfiles configuration.

Bundle layout:

```text
.github/dotfiles-manifest-slice/
  cue.mod/module.cue
  docs/codex-manifest-slice-workflow.md
  contracts/dotfiles/workflow/workflow.cue
  contracts/issues/README.md
  contracts/issues/_template/manifest.cue
  contracts/issues/_template/checks/README.md
```

Boundary:

```text
.github/dotfiles-manifest-slice
  -> repo-local workflow authority and issue-manifest support

chezmoi/private_dot_config/*
  -> materialized dotfiles surfaces
```

No dependency on `factory` or `contract.cuemod`.
