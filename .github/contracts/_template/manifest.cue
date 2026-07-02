package contract

import impl "github.com/fatb4f/dotfiles/github/dotfiles-manifest-slice/contracts/dotfiles/workflow"

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
			"cue vet <contract-path>",
			"cue export <contract-path> -e dotfilesValidationPlan",
			"cue export <contract-path> -e dotfilesCompletionReportContract",
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
			"public eval surfaces",
			"negative checks",
			"validation",
			"evidence",
			"forbidden attractors avoided",
		]
	}
}

dotfilesValidationPlan: _validation.out

dotfilesCompletionReportContract: _completion.out
