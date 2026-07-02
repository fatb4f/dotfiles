package contract

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
		publicExports: ["dotfilesImplementationCueBlockSlice"]
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
			"cue vet <contract-path>",
			"cue export <contract-path> -e dotfilesImplementationCueBlockSlice",
		]
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		name: "dotfilesCompletionReportContract"
		sections: [
			"summary",
			"implementation blocks",
			"target surfaces",
			"materialized config changes",
			"negative checks",
			"validation",
			"evidence",
			"forbidden attractors avoided",
		]
	}
}

dotfilesImplementationCueBlockSlice: [
	{workflow: _implementationWorkflow},
	{primitives: _primitives},
	{observed: _observed},
	{admissible: _admissible},
	{predicates: _predicates},
	{promotion: _promotion},
	{surfaces: _surfaces},
	{negativeFixtures: _negativeFixtures},
	{bottomCheckPlans: _bottomCheckPlans},
	{validation: _validation},
	{completion: _completion},
]
