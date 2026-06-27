# Dotfiles Manifest Slice Workflow

Minimal repo-local Codex/CUE workflow reference surface.

Layout:

```text
.github/dotfiles-manifest-slice/
  contracts/dotfiles/workflow/workflow.cue
  contracts/issues/_template/manifest.cue
  contracts/issues/45/manifest.cue
  contracts/issues/45/checks/bottom.cue
```

The GitHub issue body remains the compact contract seed. The files here provide workflow vocabulary and reference artifact shapes.
