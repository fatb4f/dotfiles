package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badInvalidPromoGateNode: agentflow.#PreMutationRejectedDomainNode & {
	id:             "write-contract"
	domain:         "cue"
	objectiveSlice: "Attempt to mutate with invalid CUE-vetted promo evidence."
	predecessors: []
	mutationPolicy: "scoped"
	promoGate: {
		requirementsImported: true
		source:               "root-response.agentflow.bootstrap"
		evidencePath:         "cue/contracts/agentflow/fixtures/bad_invalid_promo_gate.cue#node"
		evidenceGenerated:    true
		evidenceCueVetted:    true
		valid:                false
	}
	projection: {
		exported:             false
		accepted:             false
		mutationScopeDerived: false
		mutationScope: []
	}
	validationEvidence: [
		"cue vet promo evidence returned rejected outcome",
	]
	diagnostics: [
		"Promo gate evidence was generated and vetted but did not validate.",
	]
}

badInvalidPromoGate: agentflow.#PreMutationRejectedAgentFlowRun & {
	objective: "Stop before mutation because the domain promo gate is invalid."
	rootResponse: {
		objective: badInvalidPromoGate.objective
		rootConsultation: {
			viaTransport:       true
			objectivePresented: true
			responseExported:   true
			responseAccepted:   false
		}
		privateResolutionEvidence: {
			downstreamResolvedByRoot:      true
			workflowComposedOrAdopted:     true
			promoGateRequirementsImported: true
		}
		agentConsumable: {
			exposesDownstreamRegistry: false
			diagnostics: [
				"Execution envelope rejected because promo gate evidence was invalid.",
			]
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}
	diagnostics: [
		"Invalid promo gate stops the run before mutation.",
	]
}
