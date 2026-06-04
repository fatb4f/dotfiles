package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badPostMutationProjectionNode: agentflow.#RejectedPostMutationProjection & {
	id:             "write-contract"
	domain:         "cue"
	objectiveSlice: "Audit case where projection was exported after mutation."
	predecessors: []
	mutationPolicy: "scoped"
	promoGate: {
		requirementsImported: true
		source:               "root-response.agentflow.bootstrap"
		evidencePath:         "cue/contracts/agentflow/fixtures/bad_post_mutation_projection.cue#node"
		evidenceGenerated:    true
		evidenceCueVetted:    true
		valid:                true
	}
	projection: {
		name:     "agentflow.post-hoc.projection"
		exported: true
		accepted: true
	}
	firstMutation: {
		path:                "cue/contracts/agentflow/schema.cue"
		line:                1
		timestamp:           "2026-06-03T00:00:00Z"
		afterPromoGate:      false
		afterProjection:     false
		insideMutationScope: false
	}
	validationEvidence: [
		"projection export existed only after mutation",
	]
	diagnostics: [
		"First mutation occurred before selected projection export and acceptance.",
	]
}

badPostMutationProjection: agentflow.#PostViolationAuditRejectedAgentFlowRun & {
	objective: "Audit mutation before selected projection export and acceptance."
	rootResponse: {
		objective: badPostMutationProjection.objective
		rootConsultation: {
			viaMCP:             true
			objectivePresented: true
			responseExported:   true
			responseAccepted:   true
		}
		privateResolutionEvidence: {
			downstreamResolvedByRoot:      true
			workflowComposedOrAdopted:     true
			promoGateRequirementsImported: true
		}
		agentConsumable: {
			exposesDownstreamRegistry: false
			selectedWorkflow:          "agentflow.audit.bad-post-mutation-projection"
			executionEnvelope: {
				diagnosticOnly: true
			}
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}
	plan: {
		id:               "plan.agentflow.audit.post-mutation-projection"
		objective:        badPostMutationProjection.objective
		selectedWorkflow: "agentflow.audit.bad-post-mutation-projection"
		nodes: [
			badPostMutationProjectionNode,
		]
		edges: []
		derived: {
			nodeOrder: ["write-contract"]
			allNodesHavePromoGates:   true
			allExecutedNodesAccepted: false
			noMutatingNodeBeforeGate: false
		}
	}
	diagnostics: [
		"CUE/projection evidence exists eventually, but chronology proves mutation happened first.",
	]
}
