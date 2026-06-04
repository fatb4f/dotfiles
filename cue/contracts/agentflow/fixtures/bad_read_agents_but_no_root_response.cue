package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badReadAgentsButNoRootResponse: agentflow.#PreMutationRejectedAgentFlowRun & {
	objective: "Read AGENTS.cue but proceed without an exported accepted root response."
	rootResponse: {
		objective: badReadAgentsButNoRootResponse.objective
		rootConsultation: {
			viaTransport:       true
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
				"Root contract was loaded, but no accepted root response exists.",
			]
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}
	diagnostics: [
		"AGENTS.cue context is not equivalent to an exported accepted root response.",
	]
}
