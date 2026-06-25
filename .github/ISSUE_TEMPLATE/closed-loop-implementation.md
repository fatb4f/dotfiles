---
name: Dotfiles CUE manifest slice
about: Describe bounded dotfiles work as a compact CUE authority block.
title: "dotfiles: "
labels: dotfiles, contract
assignees: ""
---

# Dotfiles CUE Manifest Slice

Issue bodies should carry a compact CUE authority block or point at an issue-local
manifest under `.github/dotfiles-manifest-slice/contracts/issues/<issue>/manifest.cue`.

Keep the issue body transport-sized. Put executable checks and detailed proof
objects in repo-local CUE files, not prose.

## Authority Block

```cue
issue: {
	id:    "dotfiles.<short-id>"
	kind:  "child" | "umbrella"
	repo:  "fatb4f/dotfiles"
	title: "<issue title>"

	parent?: int
	dependsOn?: [...int]
	blocks?: [...int]

	authorityRoot: {
		root: "<repo-local source root>"
		surfaces: [...string]
	}

	intent: "<one sentence describing the intended state transition>"

	boundaries: {
		generatedArtifacts: {
			authority: false
			role: "projection/evidence only"
		}
		runtimeState: {
			authority: false
			role: "observed evidence only"
		}
	}

	closure: {
		requires: [...string]
	}
}
```

## Manifest Path

```text
.github/dotfiles-manifest-slice/contracts/issues/<issue>/manifest.cue
```

## Validation

```bash
cue vet ./.github/dotfiles-manifest-slice/contracts/issues/<issue>
cue export ./.github/dotfiles-manifest-slice/contracts/issues/<issue> -e issue
```

## Completion Report

```text
Summary:
  - authority surfaces:
  - materialized changes:
  - evidence:

Validation:
  - cue vet:
  - cue export:
```
