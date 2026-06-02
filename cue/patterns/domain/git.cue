package domain

git: #DomainNodePattern & {
	id:     "git"
	domain: "git"

	surface: {
		summary: "git state, branch, and closeout surface"
		paths: [
			".",
		]
		commands: [
			"git status",
			"git diff",
			"git commit",
		]
	}
	scopes: {
		owned: [
			"repository state",
			"staging",
			"commit history",
		]
		adjacent: [
			"source-code",
			"cue",
			"chezmoi",
		]
		forbidden: [
			"workflow execution",
			"eval generation",
			"dotfile materialization",
		]
	}

	knownGoodPatterns: [
		{
			id:      "git-state-is-observable"
			summary: "Git state is observed before any closeout decision."
		},
	]

	knownFailures: [
		{
			id:        "git-owns-workflow-execution"
			symptom:   "Git starts to encode workflow behavior."
			avoidance: "Keep git as repository-state authority only."
		},
	]

	invariants: [
		{
			id:       "git-state-is-local-authority"
			mustHold: "Git owns repository state, staging, and commit history."
		},
	]

	gatePromotionRequirements: [
		{
			id:             "git-surface-export"
			requiredBefore: "review"
			proof:          "The git domain card exports successfully."
		},
	]
}
