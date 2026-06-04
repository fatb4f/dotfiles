package fixtures

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

_objective: "Create first agentflow run-contract DAG slice."
_workflow:  "agentflow.bootstrap.contract"

_acceptedAgentFlowRun: good

good: agentflow.#AcceptedAgentFlowRun & {
	objective: _objective

	rootResponse: {
		objective: _objective
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
			selectedWorkflow:          _workflow
			executionEnvelope: {
				planID: "plan.agentflow.bootstrap"
				scope: ["cue/contracts/agentflow/**"]
			}
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}

	plan: {
		id:               "plan.agentflow.bootstrap"
		objective:        _objective
		selectedWorkflow: _workflow
		nodes: [
			{
				id:             "plan"
				domain:         "cue"
				objectiveSlice: "Generate the agentflow contract plan."
				predecessors: []
				mutationPolicy: "none"
				promoGate: {
					requirementsImported: true
					source:               "root-response.agentflow.bootstrap"
					evidencePath:         "cue/contracts/agentflow/fixtures/good.cue#plan"
					evidenceGenerated:    true
					evidenceCueVetted:    true
					valid:                true
				}
				projection: {
					exported:             false
					accepted:             false
					mutationScopeDerived: false
					mutationScope: []
				}
				validationEvidence: [
					"cue vet ./cue/contracts/agentflow/...",
				]
			},
			{
				id:             "write-contract"
				domain:         "cue"
				objectiveSlice: "Write schema and fixtures inside accepted projection scope."
				predecessors: ["plan"]
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: true
					source:               "root-response.agentflow.bootstrap"
					evidencePath:         "cue/contracts/agentflow/fixtures/good.cue#write-contract"
					evidenceGenerated:    true
					evidenceCueVetted:    true
					valid:                true
				}
				projection: {
					name:                 "agentflow.bootstrap.contract-scope"
					exported:             true
					accepted:             true
					mutationScopeDerived: true
					mutationScope: [
						"cue/contracts/agentflow/schema.cue",
						"cue/contracts/agentflow/fixtures/*.cue",
					]
				}
				firstMutation: {
					path:                "cue/contracts/agentflow/schema.cue"
					line:                1
					timestamp:           "2026-06-03T00:00:00Z"
					afterPromoGate:      true
					afterProjection:     true
					insideMutationScope: true
				}
				validationEvidence: [
					"cue fmt ./cue/contracts/agentflow/...",
					"cue vet ./cue/contracts/agentflow/...",
				]
			},
		]
		edges: [
			{from: "plan", to: "write-contract"},
		]
		derived: {
			nodeOrder: ["plan", "write-contract"]
			allNodesHavePromoGates:   true
			allExecutedNodesAccepted: true
			noMutatingNodeBeforeGate: true
		}
	}

	manifest: {
		runID:     "agentflow.bootstrap.good"
		objective: _objective
		root: {
			consultedViaTransport: true
			responseAccepted:      true
		}
		plan: {
			id:               "plan.agentflow.bootstrap"
			selectedWorkflow: _workflow
			nodeOrder: ["plan", "write-contract"]
			edges: [
				{from: "plan", to: "write-contract"},
			]
		}
		domainNodes: [
			{
				id:             "plan"
				domain:         "cue"
				mutationPolicy: "none"
				promoGate: {
					requirementsImported: true
					evidencePath:         "cue/contracts/agentflow/fixtures/good.cue#plan"
					evidenceCueVetted:    true
					valid:                true
				}
				projection: {
					exportedBeforeMutation:  false
					acceptedBeforeMutation:  false
					projectedBeforeMutation: false
					mutationScopeDerived:    false
					mutationScope: []
				}
			},
			{
				id:             "write-contract"
				domain:         "cue"
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: true
					evidencePath:         "cue/contracts/agentflow/fixtures/good.cue#write-contract"
					evidenceCueVetted:    true
					valid:                true
				}
				projection: {
					name:                    "agentflow.bootstrap.contract-scope"
					exportedBeforeMutation:  true
					acceptedBeforeMutation:  true
					projectedBeforeMutation: true
					mutationScopeDerived:    true
					mutationScope: [
						"cue/contracts/agentflow/schema.cue",
						"cue/contracts/agentflow/fixtures/*.cue",
					]
				}
				firstMutation: {
					path:                            "cue/contracts/agentflow/schema.cue"
					afterPromoGate:                  true
					afterProjection:                 true
					insideMutationScope:             true
					mutationObservedAfterProjection: true
				}
			},
		]
		derived: {
			allPromoEvidenceCueVetted: true
			allDomainNodesAccepted:    true
			noMutatingNodeBeforeGate:  true
		}
		closeout: {
			runManifestWritten:   true
			runManifestCueVetted: true
			validationCommands: [
				"cue vet ./cue/contracts/agentflow/...",
			]
			promoEvidenceSources: [
				"cue/contracts/agentflow/fixtures/good.cue#plan",
				"cue/contracts/agentflow/fixtures/good.cue#write-contract",
			]
		}
	}
}
