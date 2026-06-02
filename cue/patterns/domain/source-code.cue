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

	discovery: {
		authorityPaths: [
			"cue/",
			"shell-wrap/",
			"cue/patterns/domain/source-code.cue",
		]
		entrypoints: [
			"cue/",
			"shell-wrap/",
		]
		requiredLoads: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/domain/source-code.cue",
			"cue/patterns/projections/workflow-slice.cue",
		]
		forbiddenLoads: [
			"workflow execution",
			"eval generation",
			"materialized state",
		]
		staleSignals: [
			"source changes are being explained as runtime behavior",
			"git policy is being pulled into source edits",
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

	proofs: {
		commands: [
			"git diff -- cue/ shell-wrap/",
			"cue export ./cue/patterns/projections -e generatedCliChangeCodexSlice --out json",
		]
		artifacts: [
			"cue/patterns/domain/source-code.cue",
			"cue/patterns/projections/workflow-slice.cue",
		]
	}
}
