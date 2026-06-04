package fixtures

import git "github.com/fatb4f/dotfiles/cue/contracts/git"

badWorkflowAuthority: git.#RejectedGitContractCandidate & {
	rejected: true
	candidate: {
		repo: {
			root:   "/home/_404/src/dotfiles"
			gitDir: "/home/_404/src/dotfiles/.git"
			head: {
				sha:  "abc1234"
				kind: "branch"
				name: "main"
			}
			state: "clean"
			owns: [
				"repository state",
				"staging",
				"commit history",
				"workflow execution",
			]
		}
		patchStack: {
			invariants: {
				ordered:             true
				parentChainValid:    true
				eachPatchAdmissible: false
				finalTreeValid:      true
				noScopeInversion:    false
			}
		}
	}
	reasons: [
		"Git candidate claims workflow execution authority.",
		"Patch stack accepts final-tree validity without every patch being admissible.",
		"Patch stack allows scope inversion.",
	]
}

badWorkflowAuthorityFixturePattern: {
	classification:       "bad-as-data"
	exportShouldSucceed:  true
	validationShouldFail: false
	rationale:            "badWorkflowAuthority is an explicit rejected outcome object, not an invalid CUE fixture."
}
