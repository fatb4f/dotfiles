package a_assemble

#TaskState: "waiting" | "ready" | "running" | "terminated"

#TaskKind: "resolve_patterns" | "assemble_pattern_bundle" | "compose_flow_contract" | "vet_root_schema" | "vet_promo_gate" | "project_agent_context" | "init_agentflow_run" | "check_git_mutation" | "record_lifecycle"

#Runner: "pure-cue" | "cue-export" | "cue-vet" | "mcp-rag" | "mcp-composer" | "mcp-git" | "hookrail-evidence"

#ReferenceDependency: {
	from: string
	to:   string
	via:  "cue-reference" | "projection-evidence"
}

#TaskContract: {
	id:        string
	kind:      #TaskKind
	dependsOn: [...string]
	input:     _
	output?:   _
	runner:    #Runner
	authority: "cue"
	adapterOwnsPolicy: false
}

#FlowContract: {
	id: string
	sourceRetrieval: string

	config: {
		root:       "cue/a_assemble"
		inferTasks: false
	}

	tasks: [string]: #TaskContract

	graph: {
		edgeAuthority: "cue-references"
		cyclic:        bool
		edges:         [...#ReferenceDependency]
	}

	ambiguity: [...string]
}

#AssemblePhase: {
	"@context": "https://fatb4f.dev/ns/ralph/assemble/v0"
	"@id":      "ralph:A"
	"@type":    "ralph:PhaseNode"

	id:   "A"
	name: "assemble"

	input: {
		retrieval:         _
		retrievalAccepted: true
	}

	output: #FlowContract

	accepted: output.graph.cyclic == false && len(output.ambiguity) == 0

	control: {
		invariants: [
			"A consumes only R-accepted facts",
			"A emits a candidate graph only",
			"A does not execute",
			"A does not legitimize",
		]
	}
}
