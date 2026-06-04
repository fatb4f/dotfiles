package flow

defaultTaskChain: #FlowContract & {
	objective: "assemble selected patterns into a vetted contract run"

	access: {
		boundOverMCP:               true
		mcpIsTransportOnly:         true
		mcpServerRole:              "rag-and-flow-composer"
		agentUsesMCPAsRAG:          true
		agentUsesMCPAsFlowComposer: true
	}

	config: {
		root:       "cue/flow"
		inferTasks: false
	}

	fsm: {
		initial:  "objective_received"
		terminal: "lifecycle_recorded"
		states: [
			"objective_received",
			"patterns_resolved",
			"pattern_bundle_assembled",
			"flow_contract_composed",
			"flow_contract_imported",
			"root_schema_vetted",
			"promo_gate_vetted",
			"agent_context_projected",
			"agentflow_initialized",
			"git_mutation_checked",
			"lifecycle_recorded",
		]
	}

	tasks: {
		resolvePatterns: {
			id:   "resolve-patterns"
			kind: "resolve_patterns"
			dependsOn: []
			input: {
				objective: "assemble selected patterns into a vetted contract run"
			}
			output: {
				selectedPatterns: [
					"patterns.agentflow.mutation-gate",
				]
			}
			runner:    "mcp-rag"
			authority: "cue"
		}

		assemblePatternBundle: {
			id:   "assemble-pattern-bundle"
			kind: "assemble_pattern_bundle"
			dependsOn: ["resolve-patterns"]
			input: {
				selectedPatterns: tasks.resolvePatterns.output.selectedPatterns
			}
			output: {
				facts: []
				relations: []
				promoGateRequirements: []
				contractRefs: []
			}
			runner:    "mcp-composer"
			authority: "cue"
		}

		composeFlowContract: {
			id:   "compose-flow-contract"
			kind: "compose_flow_contract"
			dependsOn: ["assemble-pattern-bundle"]
			input: {
				patternBundle: tasks.assemblePatternBundle.output
			}
			output: {
				contractCandidate: {}
			}
			runner:    "cue-export"
			authority: "cue"
		}

		importFlowContract: {
			id:   "import-flow-contract"
			kind: "import_flow_contract"
			dependsOn: ["compose-flow-contract"]
			input: {
				contractCandidate: tasks.composeFlowContract.output.contractCandidate
			}
			output: {
				imported:     true
				contractPath: "cue/flow/generated/contract.cue"
			}
			runner:    "cue-export"
			authority: "cue"
		}

		vetRootSchema: {
			id:   "vet-root-schema"
			kind: "vet_root_schema"
			dependsOn: ["import-flow-contract"]
			input: {
				contractPath: tasks.importFlowContract.output.contractPath
			}
			output: {
				accepted: true
				diagnostics?: [...string]
			}
			runner:    "cue-vet"
			authority: "cue"
		}

		vetPromoGate: {
			id:   "vet-promo-gate"
			kind: "vet_promo_gate"
			dependsOn: ["vet-root-schema"]
			input: {
				contractPath:          tasks.importFlowContract.output.contractPath
				rootSchemaAccepted:    tasks.vetRootSchema.output.accepted
				promoGateRequirements: tasks.assemblePatternBundle.output.promoGateRequirements
			}
			output: {
				accepted: true
				diagnostics?: [...string]
			}
			runner:    "cue-vet"
			authority: "cue"
		}

		projectAgentContext: {
			id:   "project-agent-context"
			kind: "project_agent_context"
			dependsOn: ["vet-promo-gate"]
			input: {
				acceptedContract: {
					contractPath:       tasks.importFlowContract.output.contractPath
					rootSchemaAccepted: tasks.vetRootSchema.output.accepted
					promoGateAccepted:  tasks.vetPromoGate.output.accepted
				}
			}
			output: {
				agentContextProjection: {}
			}
			runner:    "cue-export"
			authority: "cue"
		}

		initAgentflowRun: {
			id:   "init-agentflow-run"
			kind: "init_agentflow_run"
			dependsOn: ["project-agent-context"]
			input: {
				agentContextProjection: tasks.projectAgentContext.output.agentContextProjection
			}
			output: {
				runManifest: {}
			}
			runner:    "cue-export"
			authority: "cue"
		}

		checkGitMutation: {
			id:   "check-git-mutation"
			kind: "check_git_mutation"
			dependsOn: ["vet-root-schema", "vet-promo-gate", "init-agentflow-run"]
			input: {
				proposedMutation: {}
				acceptedEvidence: {
					agentflowRunManifest: tasks.initAgentflowRun.output.runManifest
					rootSchemaAccepted:   tasks.vetRootSchema.output.accepted
					promoGateAccepted:    tasks.vetPromoGate.output.accepted
					contractPath:         tasks.importFlowContract.output.contractPath
				}
			}
			output: {
				admissible: true
				diagnostics?: [...string]
			}
			runner:    "cue-vet"
			authority: "cue"
		}

		recordLifecycle: {
			id:   "record-lifecycle"
			kind: "record_lifecycle"
			dependsOn: ["check-git-mutation"]
			input: {
				flowRun: {
					contractPath:          tasks.importFlowContract.output.contractPath
					agentflowRunManifest:  tasks.initAgentflowRun.output.runManifest
					gitMutationAdmissible: tasks.checkGitMutation.output.admissible
				}
			}
			output: {
				recorded:    true
				evidenceRef: "cue/contracts/lifecycle/generated/flow-run.cue"
			}
			runner:    "hookrail-evidence"
			authority: "cue"
		}
	}
}
