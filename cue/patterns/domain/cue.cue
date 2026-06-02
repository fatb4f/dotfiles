package domain

cue: #DomainNodePattern & {
	id:     "cue"
	domain: "cue"

	surface: {
		summary: "CUE contracts, schemas, and projections"
		paths: [
			"cue/",
			"cue.mods/",
		]
		commands: [
			"cue vet",
			"cue export",
		]
	}
	scopes: {
		owned: [
			"CUE contracts",
			"schema projection",
		]
		adjacent: [
			"source-code",
			"git",
			"chezmoi",
		]
		forbidden: [
			"workflow execution",
			"eval generation",
			"shell adapter implementation",
		]
	}

	discovery: {
		authorityPaths: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/domain/cue.cue",
			"cue/patterns/projections/codex-slice.cue",
		]
		entrypoints: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/projections/codex-slice.cue",
		]
		requiredLoads: [
			"cue/patterns/domain/schema.cue",
			"cue/patterns/domain/cue.cue",
			"cue/patterns/workflows/schema.cue",
		]
		forbiddenLoads: [
			"workflow execution",
			"eval generation",
			"shell adapter implementation",
		]
		staleSignals: [
			"CUE work starts carrying runtime routing",
			"projection is being edited without the schema card",
		]
	}

	knownGoodPatterns: [
		{
			id:      "cue-owns-schema-contracts"
			summary: "CUE owns contracts and projections for the atlas."
		},
	]

	knownFailures: [
		{
			id:        "cue-owns-runtime-routing"
			symptom:   "CUE starts carrying runtime routing behavior."
			avoidance: "Keep CUE focused on schema and projection."
		},
	]

	invariants: [
		{
			id:       "cue-is-contract-authority"
			mustHold: "CUE owns schema contracts and projections."
		},
	]

	gatePromotionRequirements: [
		{
			id:             "cue-card-export"
			requiredBefore: "review"
			proof:          "The cue domain card exports successfully."
		},
	]

	proofs: {
		commands: [
			"cue vet ./cue/patterns/...",
			"cue export ./cue/patterns/projections -e generatedCliChangeCodexSlice --out json",
		]
		artifacts: [
			"cue/patterns/domain/cue.cue",
			"cue/patterns/domain/schema.cue",
			"cue/patterns/projections/codex-slice.cue",
		]
	}
}
