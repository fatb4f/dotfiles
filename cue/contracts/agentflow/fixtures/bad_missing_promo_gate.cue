package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badMissingPromoGateNode: agentflow.#PreMutationRejectedDomainNode & {
	id:             "write-contract"
	domain:         "cue"
	objectiveSlice: "Attempt to mutate without imported promo gate requirements."
	predecessors: []
	mutationPolicy: "scoped"
	promoGate: {
		requirementsImported: false
		source:               "missing"
		evidenceGenerated:    false
		evidenceCueVetted:    false
		valid:                false
	}
	projection: {
		exported:             false
		accepted:             false
		mutationScopeDerived: false
		mutationScope: []
	}
	validationEvidence: []
	diagnostics: [
		"Domain node has no imported promo gate requirements.",
	]
}

badMissingPromoGate: agentflow.#PreMutationRejectedAgentFlowRun & {
	objective: "Stop before mutation because the domain node is missing promo gate requirements."
	rootResponse: {
		objective: badMissingPromoGate.objective
		rootConsultation: {
			viaMCP:             true
			objectivePresented: true
			responseExported:   true
			responseAccepted:   false
		}
		privateResolutionEvidence: {
			downstreamResolvedByRoot:      true
			workflowComposedOrAdopted:     true
			promoGateRequirementsImported: false
		}
		agentConsumable: {
			exposesDownstreamRegistry: false
			diagnostics: [
				"Execution envelope rejected because promo gate requirements were not imported.",
			]
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}
	diagnostics: [
		"Missing promo gate requirements stop the run before mutation.",
	]
}
