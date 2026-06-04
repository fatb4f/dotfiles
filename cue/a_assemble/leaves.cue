package a_assemble

#Leaf: {
	"@context": "https://fatb4f.dev/ns/ralph/assemble/v0"
	"@id":      string
	"@type":    "ralph:MetadataLeaf"

	id:            "leaf.task_graph.contract"
	parentNode:    "A"
	function:      "candidate-task-graph-schema"
	sourceSurface: "cue/flow/schema.cue"

	authority: {
		isRoot:                        false
		mayGrantLoadAdmissibility:     false
		mayGrantMutationAdmissibility: false
		mayExecute:                    false
		mayPersist:                    false
	}

	roundTrip: {
		toNodeContract: "A.contract"
		toRootGraph:    "root"
		backToLeaf:     "leaf.task_graph.contract"
	}

	invariants: [...string]
}

leaves: [#Leaf & {
	"@id": "ralph:leaf.task_graph.contract"
	invariants: ["task graph is an assembly leaf", "task graph does not own lifecycle root", "task graph does not grant mutation admissibility"]
}]
