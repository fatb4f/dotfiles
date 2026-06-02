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

	discovery: {
		authorityPaths: [
			".git/",
			"cue/patterns/domain/git.cue",
			"cue/patterns/workflows/generated-cli-change.cue",
		]
		entrypoints: [
			"git status",
			"git diff",
			"git commit",
		]
		requiredLoads: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/domain/git.cue",
			"cue/patterns/workflows/generated-cli-change.cue",
		]
		forbiddenLoads: [
			"workflow execution",
			"eval generation",
			"dotfile materialization",
		]
		staleSignals: [
			"closeout is asking about workflow behavior instead of repo state",
			"repo state is being inferred from history instead of git output",
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

	proofs: {
		commands: [
			"git status --short",
			"git diff --staged",
			"git diff",
		]
		artifacts: [
			"git status output",
			"staged diff",
			"commit SHA",
		]
	}
}
