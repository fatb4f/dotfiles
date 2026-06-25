---
name: Dotfiles manifest slice
about: Implement a bounded dotfiles slice from a repo-local CUE manifest.
title: "dotfiles: "
labels: dotfiles, cue, implementation
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

Use repo-local workflow definitions from `contracts/dotfiles/workflow`.

Issue bodies should carry a compact manifest or a path to `contracts/issues/<issue-number>/manifest.cue`.

Manifests must contain constructor calls only.
Do not import `factory`.
Do not import `contract.cuemod`.
Do not embed constructor bodies in issue text.
Do not invent alternate shapes.
Do not encode CUE checks as string metadata.
Manifests may carry bottom-check plans only; executable bottom-check proofs live in check packages.
Issue-local check adapters bind concrete proof targets internally.

```cue
package issue

import impl "github.com/fatb4f/dotfiles/contracts/dotfiles/workflow"

_implementationWorkflow: [
	{order: 1, id: "#MakeDotfilesPrimitive", constructor: impl.#MakeDotfilesPrimitive, instantiateAt: "_primitives"},
	{order: 2, id: "#MakeObservedSurface", constructor: impl.#MakeObservedSurface, instantiateAt: "_observed"},
	{order: 3, id: "#MakeAdmissibleSurface", constructor: impl.#MakeAdmissibleSurface, instantiateAt: "_admissible"},
	{order: 4, id: "#MakePredicateSet", constructor: impl.#MakePredicateSet, instantiateAt: "_predicates"},
	{order: 5, id: "#MakePromotionCandidate", constructor: impl.#MakePromotionCandidate, instantiateAt: "_promotion"},
	{order: 6, id: "#MakeSurfaceSet", constructor: impl.#MakeSurfaceSet, instantiateAt: "_surfaces"},
	{order: 7, id: "#MakeNegativeFixture", constructor: impl.#MakeNegativeFixture, instantiateAt: "_negativeFixtures"},
	{order: 8, id: "#MakeBottomCheckPlan", constructor: impl.#MakeBottomCheckPlan, instantiateAt: "_bottomCheckPlans"},
	{order: 9, id: "#MakeBottomCheckProof", constructor: impl.#MakeBottomCheckProof, instantiateAt: "checks/_negativeBottomChecks"},
	{order: 10, id: "#MakeValidationPlan", constructor: impl.#MakeValidationPlan, instantiateAt: "_validation"},
	{order: 11, id: "#MakeCompletionReport", constructor: impl.#MakeCompletionReport, instantiateAt: "_completion"},
]
```

## Manifest Shape

```cue
package issue

import impl "github.com/fatb4f/dotfiles/contracts/dotfiles/workflow"

_primitives: [
	impl.#MakeDotfilesPrimitive & {
		in: {
			name: "#<Primitive>"
			role: "<role>"
			requiredFields: ["<field>"]
			constraints: ["<constraint>"]
			closed: true
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#<Admissible>"]
		observed: ["#<Observed>"]
		candidates: ["#<Candidate>"]
		fixtures: ["_negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["normalizedDotfilesIssueManifest", "dotfilesValidationPlan", "dotfilesCompletionReportContract"]
	}
}
```

## Negative Checks

Negative checks must be loaded from an explicit check surface and must fail by structural conflict or bottom.
They must not pass because a selector is absent or because the check file was not loaded.
Do not put executable proof objects in main manifests.

```cue
#MakeIssueBottomCheckProof: {
	in: {
		name: string & !=""
		fixture: {input: _}
	}

	_name: in.name
	_fixtureInput: in.fixture.input

	_constructor: impl.#MakeBottomCheckProof & {
		in: {
			name: _name
			input: {
				evidence: "negative fixture input"
				value: _fixtureInput
			}
			target: {
				name: "#<Candidate>"
				contract: {
					evidence: "issue-local proof target"
					value: #<Candidate>
				}
			}
		}
	}

	out: _constructor.out
}
```

## Validation

```bash
cue vet ./<contract-path>
cue export ./<contract-path> -e normalizedDotfilesIssueManifest
cue export ./<contract-path> -e dotfilesValidationPlan
cue export ./<contract-path> -e dotfilesCompletionReportContract
! cue export ./<check-surface-path> -e '_negativeBottomChecks.<name>'
! rg '[t]arget:\s*_|[i]nput:\s*_|[e]xpression:|[i]sInvalid: true|[o]peratorTruthFlag|[i]nline constructor|[g]enerated.*authority' ./<contract-path>
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
