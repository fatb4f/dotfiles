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
}
