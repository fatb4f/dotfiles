# Dotfiles Issue Manifests

This directory holds repo-local implementation manifests for bounded dotfiles slices.

Expected layout:

```text
.github/dotfiles-manifest-slice/contracts/issues/<issue-number>/
  manifest.cue
  checks/
    bottom.cue
```

Rules:

- Main manifests contain constructor calls and bottom-check plans only.
- Executable bottom-check proofs live under the issue-local `checks/` package.
- Check adapters bind concrete targets internally.
- Generated artifacts are not authority.
- GitHub, shell commands, Neovim, WezTerm, chezmoi, just, and runtime tools are evidence only.
- This workflow is independent of `factory` and `contract.cuemod`.

Import path for manifests:

```cue
import impl "github.com/fatb4f/dotfiles/.github/dotfiles-manifest-slice/contracts/dotfiles/workflow"
```
