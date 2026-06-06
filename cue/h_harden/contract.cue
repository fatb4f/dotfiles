package h_harden

#AmbiguityFinding: {
	kind:     string
	path:     string
	reason:   string
	severity: "blocker"
}

#BoundaryProof: {
	noCustomRuntimeInvented:    true
	noAppServerBoundaryCrossed: true
	noUnacceptedMutationExport: true
	noUndeclaredMutation:       true
	noHiddenAppServerState:     true
	noCommitStackReasoning:     true
	cueExportBoundaryAccepted:  true
}

#AcceptedRunManifest: {
	id: string

	sourcePromotion:         string
	sourcePromotionAccepted: true

	boundaryProof: #BoundaryProof
	export: {
		command:  "cue export"
		produces: "acceptedRunManifest"
	}

	ambiguity: [...#AmbiguityFinding]
}

#HardenPhase: {
	"@context": "https://fatb4f.dev/ns/ralph/harden/v0"
	"@id":      "ralph:H"
	"@type":    "ralph:PhaseNode"

	id:   "H"
	name: "harden"

	input: {
		promotionCandidate: _
		promotionAccepted:  true
	}

	output: #AcceptedRunManifest

	accepted: output.sourcePromotionAccepted == true && output.boundaryProof.noCustomRuntimeInvented == true && output.boundaryProof.noAppServerBoundaryCrossed == true && output.boundaryProof.noUnacceptedMutationExport == true && output.boundaryProof.noUndeclaredMutation == true && output.boundaryProof.noHiddenAppServerState == true && output.boundaryProof.noCommitStackReasoning == true && output.boundaryProof.cueExportBoundaryAccepted == true && len(output.ambiguity) == 0

	control: {
		invariants: [
			"H consumes only accepted promotion evidence",
			"H proves runtime and app-server boundaries",
			"H rejects undeclared or unaccepted mutation export",
			"H is the final cue export boundary",
		]
	}
}
