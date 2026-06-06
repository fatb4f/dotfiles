package a_assemble

import retrieve "github.com/fatb4f/dotfiles/cue/r_retrieve"

#TaskState: "waiting" | "ready" | "running" | "terminated"

#TaskKind: "resolve_patterns" | "assemble_pattern_bundle" | "compose_task_graph_contract"

#Runner: "pure-cue" | "cue-export" | "cue-vet"

#ReferenceDependency: {
	from: string
	to:   string
	via:  "cue-reference"
}

#TaskContract: {
	id:   string
	kind: #TaskKind
	dependsOn: [...string]
	input:                   _
	output?:                 _
	runner:                  #Runner
	authority:               "cue"
	shapeOwner:              "cue"
	adapterOwnsPolicy:       false
	adapterDefinesTaskShape: false
}

#TaskGraphContract: {
	id:                      string
	sourceRetrievalContract: string

	config: {
		root:       "cue/a_assemble"
		inferTasks: false
	}

	tasks: [string]: #TaskContract

	graph: {
		edgeAuthority: "cue-references"
		cyclic:        bool
		edges: [...#ReferenceDependency]
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
		retrieval:         retrieve.#RetrievalContract
		retrievalAccepted: true
	}

	output: #TaskGraphContract

	accepted: output.graph.cyclic == false && len(output.ambiguity) == 0

	control: {
		invariants: [
			"A consumes only R-accepted facts",
			"A emits a candidate graph only",
			"A graph edges derive from CUE references",
			"A does not infer task shape",
			"A does not accept adapter-defined task shape",
			"A does not execute",
			"A does not load context",
			"A does not validate mutation",
			"A does not harden exports",
		]
	}
}
