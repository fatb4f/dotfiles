package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badScopeNotProjectionDerivedNode: agentflow.#RejectedScopeNotProjectionDerived & {
	id:             "write-contract"
	domain:         "cue"
	objectiveSlice: "Audit case where mutation scope came from prompt or repo inspection."
	predecessors: []
	mutationPolicy: "scoped"
	promoGate: {
		requirementsImported: true
		source:               "root-response.agentflow.bootstrap"
		evidencePath:         "cue/contracts/agentflow/fixtures/bad_scope_not_projection_derived.cue#node"
		evidenceGenerated:    true
		evidenceCueVetted:    true
		valid:                true
	}
	projection: {
		name:     "agentflow.post-hoc.scope"
		exported: true
		accepted: false
	}
	firstMutation: {
		path:                "cue/contracts/agentflow/schema.cue"
		line:                1
		timestamp:           "2026-06-03T00:00:00Z"
		afterPromoGate:      true
		afterProjection:     false
		insideMutationScope: false
	}
	validationEvidence: [
		"mutation scope was not derived from accepted projection",
	]
	diagnostics: [
		"Mutation scope came from prompt or repo inspection, not an accepted projection.",
	]
}

badScopeNotProjectionDerived: agentflow.#PostViolationAuditRejectedAgentFlowRun & {
	objective: "Audit mutation without projection-derived mutation scope."
	rootResponse: {
		objective: badScopeNotProjectionDerived.objective
		rootConsultation: {
			viaTransport:       true
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
			selectedWorkflow:          "agentflow.audit.bad-scope-not-projection-derived"
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
		id:               "plan.agentflow.audit.scope-not-projection-derived"
		objective:        badScopeNotProjectionDerived.objective
		selectedWorkflow: "agentflow.audit.bad-scope-not-projection-derived"
		nodes: [
			badScopeNotProjectionDerivedNode,
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
		"First mutation is recorded, but the run cannot satisfy accepted projection-derived scope.",
	]
}
