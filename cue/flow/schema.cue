package flow

#TaskState: "waiting" | "ready" | "running" | "terminated"

#TaskKind:
	"resolve_patterns" |
	"assemble_pattern_bundle" |
	"compose_flow_contract" |
	"import_flow_contract" |
	"vet_root_schema" |
	"vet_promo_gate" |
	"project_agent_context" |
	"init_agentflow_run" |
	"check_git_mutation" |
	"record_lifecycle"

#Runner:
	"pure-cue" |
	"cue-export" |
	"cue-vet" |
	"mcp-rag" |
	"mcp-composer" |
	"mcp-git" |
	"hookrail-evidence"

#Task: {
	id:   string
	kind: #TaskKind

	dependsOn: [...string]

	input:   _
	output?: _

	runner: #Runner

	authority:         "cue"
	adapterOwnsPolicy: false
}

#FlowContract: {
	schemaVersion: "cueflow.contract.v1"

	objective: string

	access: {
		boundOverMCP:               bool
		mcpIsTransportOnly:         true
		mcpServerRole:              "rag-and-flow-composer"
		agentUsesMCPAsRAG:          bool
		agentUsesMCPAsFlowComposer: bool
	}

	config: {
		root:       "cue/flow"
		inferTasks: false
	}

	fsm: {
		initial:  "objective_received"
		terminal: "lifecycle_recorded"
		states: [string, ...string]
	}

	tasks: [string]: #Task

	invariants: {
		contractsBindAgent:                       true
		nodesAreEntities:                         true
		patternsAreSkillProjections:              true
		patternsReplaceNodeManagedPatterns:       true
		registryIsPatternInterface:               true
		mcpIsTransportOnly:                       true
		adaptersOwnPolicy:                        false
		adaptersGrantMutationAdmissibility:       false
		rootSchemaVetRequired:                    true
		promoGateVetRequired:                     true
		mutationRequiresAcceptedContract:         true
		gitMutationRequiresRootSchemaVettedPromo: true
	}
}
