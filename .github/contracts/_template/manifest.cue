package issue

import impl "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/dotfiles/workflow"

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

_workflowIndex: [for step in _implementationWorkflow {
	order: step.order
	id: step.id
	instantiateAt: step.instantiateAt
}]

_issue: {
	number: 0
	title: "template"
	path: ".github/dotfiles-manifest-slice/contracts/issues/_template/manifest.cue"
}

_primitives: [
	impl.#MakeDotfilesPrimitive & {
		in: {
			name: "#DotfilesConfigSurface"
			role: "bounded dotfiles configuration surface"
			requiredFields: ["path", "role"]
			constraints: [
				"edits must stay inside declared target paths",
				"runtime observations are evidence only",
				"generated artifacts are not authority",
			]
			closed: true
		}
	},
]

_observed: [
	impl.#MakeObservedSurface & {
		in: {
			name: "#ObservedDotfilesSurface"
			target: "#DotfilesConfigSurface"
			paths: ["<target-path>"]
			evidence: "repo-local observed files"
		}
	},
]

_admissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name: "#AdmissibleDotfilesSurface"
			target: "#DotfilesConfigSurface"
			allows: ["<allowed-change>"]
			forbids: ["<forbidden-change>"]
		}
	},
]

_predicates: [
	impl.#MakePredicateSet & {
		in: {
			name: "#DotfilesSlicePredicates"
			predicates: [
				{id: "target-paths-declared", rule: "all materialized edits must be under declared target paths"},
				{id: "runtime-evidence-only", rule: "runtime observations are evidence only"},
				{id: "no-generated-authority", rule: "generated artifacts must not define authority"},
			]
		}
	},
]

_promotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name: "#DotfilesImplementationCandidate"
			from: "#ObservedDotfilesSurface"
			to: "#AdmissibleDotfilesSurface"
			intent: ["<intent>"]
			nonGoals: ["<non-goal>"]
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#AdmissibleDotfilesSurface"]
		observed: ["#ObservedDotfilesSurface"]
		candidates: ["#DotfilesImplementationCandidate"]
		fixtures: ["_negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: [
			"normalizedDotfilesIssueManifest",
			"dotfilesValidationPlan",
			"dotfilesCompletionReportContract",
		]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "generated-authority-rejected"
			input: {
				path: "generated/example.cue"
				role: "authority"
				isGenerated: true
			}
			expect: "bottom"
			reason: "generated artifacts are not authority"
		}
	},
]

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name: "generated-authority-bottoms"
			fixture: "generated-authority-rejected"
			checkSurface: "checks/_negativeBottomChecks"
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		name: "dotfilesValidationPlan"
		commands: [
			"cue vet ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number>",
			"cue export ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number> -e normalizedDotfilesIssueManifest",
			"cue export ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number> -e dotfilesValidationPlan",
			"cue export ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number> -e dotfilesCompletionReportContract",
			"! cue export ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number>/checks -e '_negativeBottomChecks.<name>'",
			"! rg '[t]arget:\\s*_|[i]nput:\\s*_|[e]xpression:|[i]sInvalid: true|[o]peratorTruthFlag|[i]nline constructor|[g]enerated.*authority' ./.github/dotfiles-manifest-slice/contracts/issues/<issue-number>",
		]
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		name: "dotfilesCompletionReportContract"
		sections: [
			"summary",
			"manifest workflow",
			"target surfaces",
			"materialized config changes",
			"public eval surfaces",
			"negative checks",
			"validation",
			"evidence",
			"forbidden attractors avoided",
		]
	}
}

normalizedDotfilesIssueManifest: {
	issue: _issue
	workflow: _workflowIndex
	primitives: [for item in _primitives {item.out}]
	observed: [for item in _observed {item.out}]
	admissible: [for item in _admissible {item.out}]
	predicates: [for item in _predicates {item.out}]
	promotion: [for item in _promotion {item.out}]
	surfaces: _surfaces.out
	negativeFixtures: [for item in _negativeFixtures {item.out}]
	bottomCheckPlans: [for item in _bottomCheckPlans {item.out}]
}

dotfilesValidationPlan: _validation.out

dotfilesCompletionReportContract: _completion.out
