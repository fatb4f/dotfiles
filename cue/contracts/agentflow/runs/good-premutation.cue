package runs

import agentflow "github.com/fatb4f/dotfiles/cue/contracts/agentflow"

_objective: "Install the first pre-mutation agentflow projection gate."
_workflow:  "agentflow.premutation.gate"

goodPremutation: agentflow.#AcceptedAgentFlowRun & {
	objective: _objective

	rootResponse: {
		objective: _objective
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
			selectedWorkflow:          _workflow
			executionEnvelope: {
				planID: "plan.agentflow.premutation.gate"
				scope: [
					"cue/contracts/agentflow/schema.cue",
					"cue/contracts/agentflow/fixtures/good.cue",
					"cue/contracts/agentflow/runs/*.cue",
					"bin/agentflow-check",
					"bin/agentflow-mutate",
					"docs/architecture/agentflow-premutation-gate.md",
				]
			}
		}
		audit: {
			directRegistryLoadsBeforeRootAcceptance: []
			deniedDirectRegistryLoads: []
		}
	}

	plan: {
		id:               "plan.agentflow.premutation.gate"
		objective:        _objective
		selectedWorkflow: _workflow
		nodes: [
			{
				id:             "project-gate"
				domain:         "cue"
				objectiveSlice: "Export and accept the projection-derived mutation scope before mutation."
				predecessors: []
				mutationPolicy: "none"
				promoGate: {
					requirementsImported: true
					source:               "root-response.agentflow.premutation.gate"
					evidencePath:         "cue/contracts/agentflow/runs/good-premutation.cue#project-gate"
					evidenceGenerated:    true
					evidenceCueVetted:    true
					valid:                true
				}
				projection: {
					name:                 "agentflow.premutation.gate-scope"
					exported:             true
					accepted:             true
					mutationScopeDerived: false
					mutationScope: []
				}
				validationEvidence: [
					"bin/agentflow-check cue/contracts/agentflow/runs/good-premutation.cue",
				]
			},
			{
				id:             "write-gate"
				domain:         "cue"
				objectiveSlice: "Write the pre-mutation checker, run manifests, and architecture note."
				predecessors: ["project-gate"]
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: true
					source:               "root-response.agentflow.premutation.gate"
					evidencePath:         "cue/contracts/agentflow/runs/good-premutation.cue#write-gate"
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
						"cue/contracts/agentflow/schema.cue",
						"cue/contracts/agentflow/fixtures/good.cue",
						"cue/contracts/agentflow/runs/*.cue",
						"bin/agentflow-check",
						"bin/agentflow-mutate",
						"docs/architecture/agentflow-premutation-gate.md",
					]
				}
				firstMutation: {
					path:                "cue/contracts/agentflow/runs/good-premutation.cue"
					line:                1
					timestamp:           "2026-06-03T00:00:00Z"
					afterPromoGate:      true
					afterProjection:     true
					insideMutationScope: true
				}
				validationEvidence: [
					"cue fmt ./cue/contracts/agentflow/...",
					"cue vet ./cue/contracts/agentflow/...",
					"bin/agentflow-check cue/contracts/agentflow/runs/good-premutation.cue",
					"bin/agentflow-mutate --manifest cue/contracts/agentflow/runs/good-premutation.cue -- touch tmp/agentflow-proof-ok",
				]
			},
		]
		edges: [
			{from: "project-gate", to: "write-gate"},
		]
		derived: {
			nodeOrder: ["project-gate", "write-gate"]
			allNodesHavePromoGates:   true
			allExecutedNodesAccepted: true
			noMutatingNodeBeforeGate: true
		}
	}

	manifest: {
		runID:     "agentflow.premutation.good"
		objective: _objective
		root: {
			consultedViaMCP:  true
			responseAccepted: true
		}
		plan: {
			id:               "plan.agentflow.premutation.gate"
			selectedWorkflow: _workflow
			nodeOrder: ["project-gate", "write-gate"]
			edges: [
				{from: "project-gate", to: "write-gate"},
			]
		}
		domainNodes: [
			{
				id:             "project-gate"
				domain:         "cue"
				mutationPolicy: "none"
				promoGate: {
					requirementsImported: true
					evidencePath:         "cue/contracts/agentflow/runs/good-premutation.cue#project-gate"
					evidenceCueVetted:    true
					valid:                true
				}
				projection: {
					name:                    "agentflow.premutation.gate-scope"
					exportedBeforeMutation:  true
					acceptedBeforeMutation:  true
					projectedBeforeMutation: true
					mutationScopeDerived:    false
					mutationScope: []
				}
			},
			{
				id:             "write-gate"
				domain:         "cue"
				mutationPolicy: "scoped"
				promoGate: {
					requirementsImported: true
					evidencePath:         "cue/contracts/agentflow/runs/good-premutation.cue#write-gate"
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
						"cue/contracts/agentflow/schema.cue",
						"cue/contracts/agentflow/fixtures/good.cue",
						"cue/contracts/agentflow/runs/*.cue",
						"bin/agentflow-check",
						"bin/agentflow-mutate",
						"docs/architecture/agentflow-premutation-gate.md",
					]
				}
				firstMutation: {
					path:                            "cue/contracts/agentflow/runs/good-premutation.cue"
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
				"cue fmt ./cue/contracts/agentflow/...",
				"cue vet ./cue/contracts/agentflow/...",
				"bin/agentflow-check cue/contracts/agentflow/runs/good-premutation.cue",
				"bin/agentflow-mutate --manifest cue/contracts/agentflow/runs/good-premutation.cue -- touch tmp/agentflow-proof-ok",
			]
			promoEvidenceSources: [
				"cue/contracts/agentflow/runs/good-premutation.cue#project-gate",
				"cue/contracts/agentflow/runs/good-premutation.cue#write-gate",
			]
		}
	}
}
