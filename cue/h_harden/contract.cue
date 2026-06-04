package h_harden

#DurableFact: {
	id: string
	sourceEvidence: string
	claim: string
}

#PatternRef: {
	id: string
	path: string
}

#AmbiguityFinding: {
	kind: string
	path: string
	reason: string
	severity: "blocker"
}

#LifecycleRecord: {
	id: string

	sourceRun: string
	sourceRunAccepted: true

	persisted: bool

	distilledFacts:   [...#DurableFact]
	promotedPatterns: [...#PatternRef]
	retiredAmbiguity: [...#AmbiguityFinding]

	ambiguity: [...#AmbiguityFinding]
}

#HardenPhase: {
	"@context": "https://fatb4f.dev/ns/ralph/harden/v0"
	"@id":      "ralph:H"
	"@type":    "ralph:PhaseNode"

	id:   "H"
	name: "harden"

	input: {
		runManifest: _
		runAccepted: true
	}

	output: #LifecycleRecord

	accepted: output.persisted == true && output.sourceRunAccepted == true && len(output.ambiguity) == 0

	control: {
		invariants: [
			"H is the only durable memory boundary",
			"H consumes only accepted run evidence",
			"durable facts cite accepted evidence",
		]
	}
}
