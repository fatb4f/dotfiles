package runs

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badMissingPromo: agentflow.#AgentFlowRun & {
	objective: "Reject a mutating run manifest with missing promo gate evidence."

	rootResponse: {
		objective: badMissingPromo.objective
		rootConsultation: {
			viaMCP:             true
			objectivePresented: true
			responseExported:   true
			responseAccepted:   true
		}
		privateResolutionEvidence: {
			downstreamResolvedByRoot:      true
			workflowComposedOrAdopted:     true
			promoGateRequirementsImported: false
		}
		agentConsumable: {
			exposesDownstreamRegistry: false
			selectedWorkflow:          "agentflow.premutation.bad-missing-promo"
			executionEnvelope: {
				planID: "plan.agentflow.bad-missing-promo"
			}
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}

	plan: {
		id:               "plan.agentflow.bad-missing-promo"
		objective:        badMissingPromo.objective
		selectedWorkflow: "agentflow.premutation.bad-missing-promo"
		nodes: [
			{
				id:             "write-gate"
				domain:         "cue"
				objectiveSlice: "Attempt a scoped mutation without imported promo evidence."
				predecessors: []
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: false
					source:               "missing"
					evidencePath:         "cue/contracts/agentflow/runs/bad-missing-promo.cue#write-gate"
					evidenceGenerated:    false
					evidenceCueVetted:    false
					valid:                false
				}
				projection: {
					name:                 "agentflow.premutation.gate-scope"
					exported:             true
					accepted:             true
					mutationScopeDerived: true
					mutationScope: [
						"cue/contracts/agentflow/runs/*.cue",
					]
				}
				firstMutation: {
					path:                "cue/contracts/agentflow/runs/bad-missing-promo.cue"
					timestamp:           "2026-06-03T00:00:00Z"
					afterPromoGate:      false
					afterProjection:     true
					insideMutationScope: true
				}
				validationEvidence: []
			},
		]
		edges: []
		derived: {
			nodeOrder: ["write-gate"]
			allNodesHavePromoGates:   false
			allExecutedNodesAccepted: false
			noMutatingNodeBeforeGate: false
		}
	}

	manifest: {
		runID:     "agentflow.premutation.bad-missing-promo"
		objective: badMissingPromo.objective
		root: {
			consultedViaMCP:  true
			responseAccepted: true
		}
		plan: {
			id:               "plan.agentflow.bad-missing-promo"
			selectedWorkflow: "agentflow.premutation.bad-missing-promo"
			nodeOrder: ["write-gate"]
			edges: []
		}
		domainNodes: [
			{
				id:             "write-gate"
				domain:         "cue"
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: false
					evidencePath:         "cue/contracts/agentflow/runs/bad-missing-promo.cue#write-gate"
					evidenceCueVetted:    false
					valid:                false
				}
				projection: {
					name:                    "agentflow.premutation.gate-scope"
					exportedBeforeMutation:  true
					acceptedBeforeMutation:  true
					projectedBeforeMutation: true
					mutationScopeDerived:    true
					mutationScope: [
						"cue/contracts/agentflow/runs/*.cue",
					]
				}
				firstMutation: {
					path:                            "cue/contracts/agentflow/runs/bad-missing-promo.cue"
					afterPromoGate:                  false
					afterProjection:                 true
					insideMutationScope:             true
					mutationObservedAfterProjection: true
				}
			},
		]
		derived: {
			allPromoEvidenceCueVetted: false
			allDomainNodesAccepted:    false
			noMutatingNodeBeforeGate:  false
		}
		closeout: {
			runManifestWritten:   true
			runManifestCueVetted: false
		}
	}
}
