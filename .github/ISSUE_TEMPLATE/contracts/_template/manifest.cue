package contract

import impl "github.com/fatb4f/dotfiles/github/contracts/meta/impl"

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#IssueTemplateContractSurface"
			role: "constructor-call-only issue template contract surface"
			requiredFields: ["path", "role"]
			constraints: [
				"constructor bodies stay in the repo-local implementation package",
				"generated artifacts are projection evidence only",
				"installed templates carry constructor calls, not constructor definitions",
			]
			closed: true
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#IssueTemplateContractSurface"]
		observed: ["_primitives"]
		candidates: ["_completion"]
		fixtures: ["negativeIssueTemplateFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: [
			"issueTemplateValidationPlan",
			"issueTemplateCompletionReportContract",
		]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "generatedAuthorityAccepted"
			violates: "generated artifact authority boundary"
			refusal: "generated artifacts are projection evidence only"
			input: {
				path: "generated/issue-template/manifest.cue"
				generatedArtifactsAreAuthority: true
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "inlineConstructorDefinitionsAccepted"
			violates: "constructor call compactness boundary"
			refusal: "installed issue templates carry constructor calls, not constructor definitions"
			input: {
				path: "<contract-path>/manifest.cue"
				inlineConstructorDefinitions: true
			}
		}
	},
]

negativeIssueTemplateFixtures: {
	generatedAuthorityAccepted: _negativeFixtures[0].out
	inlineConstructorDefinitionsAccepted: _negativeFixtures[1].out
}

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name: "generatedAuthorityAccepted"
			fixture: negativeIssueTemplateFixtures.generatedAuthorityAccepted.id
			checkSurface: "_negativeBottomChecks"
			checkFile: "<contract-path>/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name: "inlineConstructorDefinitionsAccepted"
			fixture: negativeIssueTemplateFixtures.inlineConstructorDefinitionsAccepted.id
			checkSurface: "_negativeBottomChecks"
			checkFile: "<contract-path>/checks"
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "<contract-path>"
		validBaselineExpr: "_surfaces.out"
		publicExpr: "issueTemplateCompletionReportContract"
		bottomChecks: [for plan in _bottomCheckPlans {plan.out.name}]
		checkFile: "<contract-path>/checks"
		checkSurface: "_negativeBottomChecks"
		forbiddenPattern: "[i]nlineConstructorDefinitions: true|[g]eneratedArtifactsAreAuthority: true"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [for fixture in _negativeFixtures {fixture.out.id}]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
		evidence: ["repo-local constructor import", "constructor calls only", "generated artifacts are evidence only"]
	}
}

issueTemplateValidationPlan: _validation.out
issueTemplateCompletionReportContract: _completion.out
