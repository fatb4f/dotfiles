package domain

sourceCode: #DomainNodePattern & {
	id:     "source-code"
	domain: "source-code"

	surface: {
		summary: "tracked source tree and code-change surface"
		paths: [
			"cue/",
			"shell-wrap/",
		]
	}
	scopes: {
		owned: [
			"tracked source files",
			"code changes",
		]
		adjacent: [
			"git",
			"cue",
			"shell-wrap",
		]
		forbidden: [
			"workflow execution",
			"eval generation",
			"materialized state",
		]
	}

	knownGoodPatterns: [
		{
			id:      "source-code-is-diffable"
			summary: "Source code is represented as diffs, not runtime behavior."
		},
	]

	knownFailures: [
		{
			id:        "source-code-owns-git-policy"
			symptom:   "Source code starts to define git rules."
			avoidance: "Keep git policy in the git card."
		},
	]

	invariants: [
		{
			id:       "source-code-stays-descriptive"
			mustHold: "Source-code cards describe tracked changes, not execution."
		},
	]

	gatePromotionRequirements: [
		{
			id:             "source-code-card-export"
			requiredBefore: "review"
			proof:          "The source-code domain card exports successfully."
		},
	]
}
