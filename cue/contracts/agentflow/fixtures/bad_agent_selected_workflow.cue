package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badAgentSelectedWorkflow: agentflow.#PreMutationRejectedAgentFlowRun & {
	objective: "Agent chooses a workflow and encodes it as evidence after the fact."
	rootResponse: {
		objective: badAgentSelectedWorkflow.objective
		rootConsultation: {
			viaTransport:       true
			objectivePresented: true
			responseExported:   true
			responseAccepted:   false
		}
		privateResolutionEvidence: {
			downstreamResolvedByRoot:      false
			workflowComposedOrAdopted:     false
			promoGateRequirementsImported: false
		}
		agentConsumable: {
			exposesDownstreamRegistry: false
			selectedWorkflow:          "agent-selected.workflow"
			diagnostics: [
				"Selected workflow did not come from cue-flow root resolution.",
			]
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}
	diagnostics: [
		"Workflow selection must be composed or admitted by cue-flow before planning.",
	]
}
