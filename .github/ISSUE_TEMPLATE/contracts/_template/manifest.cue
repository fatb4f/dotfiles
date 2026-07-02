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

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "generatedAuthorityAccepted"
			violates: "generated artifact authority boundary"
			refusal: "generated artifacts are projection evidence only"
			input: {
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
				inlineConstructorDefinitions: true
			}
		}
	},
]

negativeIssueTemplateFixtures: {
	generatedAuthorityAccepted: _negativeFixtures[0].out
	inlineConstructorDefinitionsAccepted: _negativeFixtures[1].out
}
