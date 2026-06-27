# Codex Manifest Slice Workflow

Codex implementation slices start from compact issue bodies.

Workflow:

1. Read the GitHub issue body.
2. Treat the issue body as the compact contract seed.
3. Use `.github/dotfiles-manifest-slice/contracts/dotfiles/workflow` as the repo-local workflow vocabulary when a manifest/reference shape is required.
4. Use `.github/dotfiles-manifest-slice/contracts/issues/_template/manifest.cue` as the generic artifact shape.
5. Use `.github/dotfiles-manifest-slice/contracts/issues/45` as the canonical reference implementation shape.
6. Apply bounded repo changes with normal patch work.
7. Run declared validation commands.
8. Return summary, changed surfaces, validation, evidence, and remaining risks.

Boundaries:

- GitHub issue bodies are the compact transport/control seed.
- Workflow CUE defines vocabulary and reference artifact shape.
- Reference manifests are examples, not mandatory issue-tracking scaffolding.
- GitHub, shell commands, Neovim, WezTerm, chezmoi, just, and runtime tools provide evidence only.
- Generated artifacts, stringified CUE expressions, boolean invalidity flags, and operator-supplied predicate truth are not authority.
