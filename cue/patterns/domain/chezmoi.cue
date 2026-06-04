package domain

chezmoi: #EntityProjection & {
	id:   "chezmoi"
	area: "chezmoi"

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

	discovery: {
		referencePaths: [
			"chezmoi/AGENTS.md",
			"chezmoi/",
			"cue/patterns/domain/chezmoi.cue",
		]
		startPoints: [
			"chezmoi status",
			"chezmoi diff",
			"chezmoi apply",
		]
		suggestedLoads: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/domain/chezmoi.cue",
		]
		forbiddenLoads: [
			"workflow execution",
			"eval generation",
			"shell adapter implementation",
		]
		staleSignals: [
			"dotfile materialization is being inferred from git history",
			"chezmoi work is being driven from runtime traces",
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

	proofs: {
		commands: [
			"chezmoi status",
			"chezmoi diff",
			"chezmoi apply",
		]
		artifacts: [
			"chezmoi status output",
			"chezmoi diff output",
			"rendered dotfiles",
		]
	}
}
