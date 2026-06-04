package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badDirectRegistryLoadBeforeRootAcceptance: agentflow.#PreMutationRejectedAgentFlowRun & {
	objective: "Inspect downstream registry directly before root response acceptance."
	rootResponse: {
		objective: badDirectRegistryLoadBeforeRootAcceptance.objective
		rootConsultation: {
			viaMCP:             true
			objectivePresented: true
			responseExported:   false
			responseAccepted:   false
		}
		privateResolutionEvidence: {
			downstreamResolvedByRoot:      false
			workflowComposedOrAdopted:     false
			promoGateRequirementsImported: false
		}
		agentConsumable: {
			exposesDownstreamRegistry: false
			diagnostics: [
				"Direct registry load was requested before root acceptance.",
			]
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: [
				"cue/patterns/workflows/*.cue",
			]
			deniedDirectRegistryLoads: [
				"cue/patterns/workflows/*.cue",
			]
		}
	}
	diagnostics: [
		"Downstream registry inspection before root acceptance is denied and stops the run.",
	]
}
