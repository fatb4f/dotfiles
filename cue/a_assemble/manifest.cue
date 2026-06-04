package a_assemble

manifest: {
	"@context": "https://fatb4f.dev/ns/ralph/assemble/v0"
	"@id":      "ralph:A"
	"@type":    "ralph:PhaseManifest"

	id:    "A"
	label: "Assemble"

	scope: {
		owns: ["candidate graph assembly", "task contract binding", "CUE-reference edge model"]
		mayRead: ["R.output.RetrievalContract", "leaf.task_graph.contract"]
		mayWrite: ["TaskGraphContract"]
		mayExecute: false
		mayPersist: false
	}

	boundaries: {
		upstream: ["R"]
		downstream: ["L"]
		forbidden: ["consume unaccepted retrieval", "execute tasks", "grant mutation admissibility", "call task.Fill"]
		authorityMode: "contract"
	}

	inputs: [{id: "retrievalContract", from: "R", kind: "RetrievalContract", acceptedRequired: true}]
	outputs: [{id: "taskGraphContract", to: "L", kind: "TaskGraphContract", acceptedBy: "A.accepted"}]

	control: {
		invariants: ["graph edges derive from CUE references", "inferTasks is false", "adapter does not define task shape"]
		rejects: ["retrieval_unaccepted", "task_graph_cyclic", "explicit_edge_claims_authority", "adapter_task_shape"]
		acceptance: ["R.accepted == true", "graph.cyclic == false", "len(ambiguity) == 0"]
	}
}
