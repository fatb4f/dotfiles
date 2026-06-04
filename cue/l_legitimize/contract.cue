package l_legitimize

#GateResult: {
	accepted: bool
	diagnostics: [...string]
}

#RunnerBoundaries: {
	accepted:                     bool
	agentOwnsPolicy:              false
	runnerOwnsPolicy:             false
	adapterOwnsPolicy:            false
	agentMayCompleteTaskDirectly: false
	runnerMayCompleteTask:        true
}

#MutationAdmissibility: {
	accepted:                 bool
	requiresAcceptedContract: true
}

#ValidationFacts: {
	rootSchema:            #GateResult
	promoGate:             #GateResult
	runnerBoundaries:      #RunnerBoundaries
	mutationAdmissibility: #MutationAdmissibility
	ambiguity: [...string]
}

#LegitimizePhase: {
	"@context": "https://fatb4f.dev/ns/ralph/legitimize/v0"
	"@id":      "ralph:L"
	"@type":    "ralph:PhaseNode"

	id:   "L"
	name: "legitimize"

	input: {
		taskGraphContract:         _
		taskGraphContractAccepted: true
	}

	output: #ValidationFacts

	accepted: output.rootSchema.accepted == true && output.promoGate.accepted == true && output.runnerBoundaries.accepted == true && output.mutationAdmissibility.accepted == true && len(output.ambiguity) == 0

	control: {
		invariants: [
			"L is the last pure-CUE authority gate before execution",
			"agent owns no policy",
			"runner owns no policy",
			"adapter owns no policy",
			"mutation requires accepted contract",
		]
	}
}
