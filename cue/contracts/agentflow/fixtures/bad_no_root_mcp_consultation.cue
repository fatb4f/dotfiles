package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badNoRootMCPConsultation: agentflow.#PreMutationRejectedAgentFlowRun & {
	objective: "Read AGENTS.cue but do not consult root via MCP."
	rootResponse: {
		objective: badNoRootMCPConsultation.objective
		rootConsultation: {
			viaTransport:       false
			objectivePresented: false
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
				"AGENTS.cue was read as context, but no root MCP consultation occurred.",
			]
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}
	diagnostics: [
		"Root MCP consultation is required before workflow selection or mutation.",
	]
}
