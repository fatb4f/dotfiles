package domain

chezmoi: #DomainNodePattern & {
	id:     "chezmoi"
	domain: "chezmoi"

	surface: {
		summary: "chezmoi source and materialization surface"
		paths: [
			"chezmoi/",
		]
		commands: [
			"chezmoi status",
			"chezmoi diff",
			"chezmoi apply",
		]
	}
	scopes: {
		owned: [
			"source state",
			"rendered dotfiles",
		]
		adjacent: [
			"git",
			"source-code",
			"cue",
		]
		forbidden: [
			"workflow execution",
			"eval generation",
			"shell adapter implementation",
		]
	}

	knownGoodPatterns: [
		{
			id:      "chezmoi-separates-source-from-rendered-state"
			summary: "chezmoi keeps source state distinct from rendered dotfiles."
		},
	]

	knownFailures: [
		{
			id:        "chezmoi-owns-git-history"
			symptom:   "chezmoi starts defining git behavior."
			avoidance: "Keep history and staging in the git card."
		},
	]

	invariants: [
		{
			id:       "chezmoi-is-materialization-authority"
			mustHold: "chezmoi owns source and rendered dotfile materialization."
		},
	]

	gatePromotionRequirements: [
		{
			id:             "chezmoi-card-export"
			requiredBefore: "review"
			proof:          "The chezmoi domain card exports successfully."
		},
	]
}
