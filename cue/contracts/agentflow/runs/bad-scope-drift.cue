package runs

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

badScopeDrift: agentflow.#AgentFlowRun & {
	objective: "Reject a mutating run manifest where mutation does not stay inside projected scope."

	rootResponse: {
		objective: badScopeDrift.objective
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
			selectedWorkflow:          "agentflow.premutation.bad-scope-drift"
			executionEnvelope: {
				planID: "plan.agentflow.bad-scope-drift"
				scope: [
					"cue/contracts/agentflow/runs/*.cue",
				]
			}
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}

	plan: {
		id:               "plan.agentflow.bad-scope-drift"
		objective:        badScopeDrift.objective
		selectedWorkflow: "agentflow.premutation.bad-scope-drift"
		nodes: [
			{
				id:             "write-out-of-scope"
				domain:         "cue"
				objectiveSlice: "Attempt a mutation outside the projected mutation scope."
				predecessors: []
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: true
					source:               "root-response.agentflow.premutation.gate"
					evidencePath:         "cue/contracts/agentflow/runs/bad-scope-drift.cue#write-out-of-scope"
					evidenceGenerated:    true
					evidenceCueVetted:    true
					valid:                true
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
					path:                "docs/architecture/agentflow-premutation-gate.md"
					timestamp:           "2026-06-03T00:00:00Z"
					afterPromoGate:      true
					afterProjection:     true
					insideMutationScope: false
				}
				validationEvidence: [
					"mutation path is not covered by the projected scope",
				]
			},
		]
		edges: []
		derived: {
			nodeOrder: ["write-out-of-scope"]
			allNodesHavePromoGates:   true
			allExecutedNodesAccepted: false
			noMutatingNodeBeforeGate: false
		}
	}

	manifest: {
		runID:     "agentflow.premutation.bad-scope-drift"
		objective: badScopeDrift.objective
		root: {
			consultedViaTransport: true
			responseAccepted:      true
		}
		plan: {
			id:               "plan.agentflow.bad-scope-drift"
			selectedWorkflow: "agentflow.premutation.bad-scope-drift"
			nodeOrder: ["write-out-of-scope"]
			edges: []
		}
		domainNodes: [
			{
				id:             "write-out-of-scope"
				domain:         "cue"
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: true
					evidencePath:         "cue/contracts/agentflow/runs/bad-scope-drift.cue#write-out-of-scope"
					evidenceCueVetted:    true
					valid:                true
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
					path:                            "docs/architecture/agentflow-premutation-gate.md"
					afterPromoGate:                  true
					afterProjection:                 true
					insideMutationScope:             false
					mutationObservedAfterProjection: true
				}
			},
		]
		derived: {
			allPromoEvidenceCueVetted: true
			allDomainNodesAccepted:    false
			noMutatingNodeBeforeGate:  false
		}
		closeout: {
			runManifestWritten:   true
			runManifestCueVetted: false
		}
	}
}
