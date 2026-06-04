package flow

#TaskState: "waiting" | "ready" | "running" | "terminated"

#TaskKind:
	"resolve_patterns" |
	"assemble_pattern_bundle" |
	"compose_contract" |
	"vet_contract" |
	"project_agent_context" |
	"check_git_mutation" |
	"record_lifecycle"

#Runner: "pure-cue" | "cue-export" | "cue-vet" | "mcp-rag" | "mcp-git"

#Task: {
	id:   string
	kind: #TaskKind

	dependsOn: [...string]

	input: _
	output?: _

	runner: #Runner

	authority:         "cue"
	adapterOwnsPolicy: false
}

#FlowContract: {
	schemaVersion: "cueflow.contract.v1"

	objective: string

	tasks: [string]: #Task

	invariants: {
		contractsBindAgent:              true
		nodesAreEntities:                true
		patternsAreSkillProjections:     true
		registryIsPatternInterface:      true
		adaptersOwnPolicy:               false
		mutationRequiresAcceptedContract: true
	}
}
