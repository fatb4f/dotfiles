# Codex Manifest Slice Workflow

Codex implementation slices start from compact issue bodies. The issue body should contain intent and, when available, a repo-local manifest path such as `.github/dotfiles-manifest-slice/contracts/issues/<issue-number>/manifest.cue`.

This workflow is local to the dotfiles repository. It does not import or depend on `factory` or `contract.cuemod`.

Workflow:

1. Run `gh issue view <number>` to read the compact issue body.
2. Open the manifest path when the body provides one.
3. Treat `.github/dotfiles-manifest-slice/contracts/dotfiles/workflow` as the repo-local constructor surface for this workflow.
4. Expand the manifest into concrete dotfiles changes with normal patch work.
   Main manifests carry constructor calls and bottom-check plans only.
   Check packages carry executable bottom-check proofs through issue-local adapters that bind concrete targets.
5. Run the manifest's generated validation plan.
6. Return the manifest's completion report sections.

Boundaries:

- Dotfiles manifests and `.github/dotfiles-manifest-slice/contracts/dotfiles/workflow` define repo-local workflow shape.
- Observed input, admissible input, lowered objects, proof objects, and materialized surfaces are separate phases.
- Proof constructors must not take Codex-authored top placeholders for targets; check adapters bind targets internally.
- GitHub, shell commands, Neovim, WezTerm, chezmoi, just, and runtime tools provide evidence only.
- Generated artifacts, stringified CUE expressions, boolean invalidity flags, and operator-supplied predicate truth are not authority.
- Factory, contract.cuemod, Go wrappers, MCP transport, GitHub Projects mutation, and automatic materializers are outside this workflow unless a later issue explicitly promotes them.
