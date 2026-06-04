package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badRegistryExposedInAgentResponse: agentflow.#PreMutationRejectedAgentFlowRun & {
	objective: "Expose downstream workflow candidates in the agent-consumable response."
	rootResponse: {
		objective: badRegistryExposedInAgentResponse.objective
		rootConsultation: {
			viaTransport:       true
			objectivePresented: true
			responseExported:   true
			responseAccepted:   false
		}
		privateResolutionEvidence: {
			downstreamResolvedByRoot:      true
			workflowComposedOrAdopted:     false
			promoGateRequirementsImported: false
		}
		agentConsumable: {
			exposesDownstreamRegistry: true
			diagnostics: [
				"Agent-consumable response exposed downstream registry as a selection surface.",
			]
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}
	diagnostics: [
		"Root response must expose an execution envelope, not the private registry.",
	]
}
