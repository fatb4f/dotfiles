package p_perform

manifest: {
	"@context": "https://fatb4f.dev/ns/ralph/perform/v0"
	"@id":      "ralph:P"
	"@type":    "ralph:PhaseManifest"

	id: "P"
	label: "Perform"

	scope: {
		owns: ["accepted task execution", "adapter invocation evidence", "task.Fill evidence", "run manifest emission"]
		mayRead: ["A.output.FlowContract", "L.output.ValidationFacts", "leaf.agentflow.run_manifest", "leaf.registry.execution"]
		mayWrite: ["RunManifest", "execution evidence"]
		mayExecute: true
		mayPersist: false
	}

	boundaries: {
		upstream: ["L"]
		downstream: ["H"]
		forbidden: ["execute before L.accepted", "authorize mutation", "broaden mutation scope", "persist durable memory"]
		authorityMode: "evidence"
	}

	inputs: [
		{id: "flowContract", from: "A", kind: "FlowContract", acceptedRequired: true},
		{id: "validationFacts", from: "L", kind: "ValidationFacts", acceptedRequired: true},
	]
	outputs: [{id: "runManifest", to: "H", kind: "RunManifest", acceptedBy: "P.accepted"}]

	control: {
		invariants: ["L.accepted == true", "executedOnlyAcceptedTasks == true", "agentCalledRawFill == false", "runner owns no policy"]
		rejects: ["raw_fill_called_by_agent", "taskfill_unvalidated", "nonaccepted_task_executed", "mutation_outside_scope"]
		acceptance: ["only accepted tasks executed", "run evidence emitted", "len(ambiguity) == 0"]
	}
}
