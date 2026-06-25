---
name: Dotfiles manifest slice
about: Implement a bounded dotfiles slice from a repo-local GitHub workflow bundle.
title: "dotfiles: "
---

# Dotfiles Manifest Slice

## Tracking

```text
Parent:
Depends on:
Blocks:
Manifest path:
```

## Goal

```text
Implement:
  -

Do not implement:
  -
```

## Dotfiles Workflow Authority

Use the repo-local workflow bundle under `.github/dotfiles-manifest-slice`.

Issue bodies should carry a compact manifest or a path to:

```text
.github/dotfiles-manifest-slice/contracts/issues/<issue-number>/manifest.cue
```

Workflow definitions live at:

```text
.github/dotfiles-manifest-slice/contracts/dotfiles/workflow
```

Manifests must contain constructor calls only.
Do not import `factory`.
Do not import `contract.cuemod`.
Do not embed constructor bodies in issue text.
Do not invent alternate shapes.
Do not encode CUE checks as string metadata.
Manifests may carry bottom-check plans only; executable bottom-check proofs live in check packages.
Issue-local check adapters bind concrete proof targets internally.

## Manifest Import

```cue
import impl "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/dotfiles/workflow"
```

## Implementation Workflow

```text
1.  #MakeDotfilesPrimitive     -> _primitives
2.  #MakeObservedSurface       -> _observed
3.  #MakeAdmissibleSurface     -> _admissible
4.  #MakePredicateSet          -> _predicates
5.  #MakePromotionCandidate    -> _promotion
6.  #MakeSurfaceSet            -> _surfaces
7.  #MakeNegativeFixture       -> _negativeFixtures
8.  #MakeBottomCheckPlan       -> _bottomCheckPlans
9.  #MakeBottomCheckProof      -> checks/_negativeBottomChecks
10. #MakeValidationPlan        -> _validation
11. #MakeCompletionReport      -> _completion
```

## Validation

```bash
cue vet ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number>
cue export ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number> -e normalizedDotfilesIssueManifest
cue export ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number> -e dotfilesValidationPlan
cue export ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number> -e dotfilesCompletionReportContract
```

## Completion Report

```text
Summary:
  - workflow files:
  - manifest workflow:
  - target surfaces:
  - materialized config changes:
  - public eval surfaces:
  - negative checks:
  - evidence:
  - forbidden attractors avoided:

Validation:
  - cue vet:
  - constructor exports:
  - negative bottom checks:
  - forbidden-attractor search:
```

Stop once the declared dotfiles surfaces export and the loaded negative checks bottom.
