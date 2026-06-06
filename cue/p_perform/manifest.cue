package p_perform

manifest: {
	"@context": "https://fatb4f.dev/ns/ralph/promote/v0"
	"@id":      "ralph:P"
	"@type":    "ralph:PhaseManifest"

	id:    "P"
	label: "Promote"

	scope: {
		owns: ["observed mutation validation", "changed path evidence", "validation evidence", "promotion candidate emission"]
		mayRead: ["A.output.TaskGraphContract", "L.output.LoadedContext", "worktree diff evidence", "validation evidence"]
		mayWrite: ["PromotionCandidate"]
		mayExecute: false
		mayPersist: false
	}

	boundaries: {
		upstream: ["L"]
		downstream: ["H"]
		forbidden: ["validate before L.accepted", "authorize mutation", "broaden mutation scope", "persist durable memory", "export final manifest"]
		authorityMode: "evidence"
	}

	inputs: [
		{id: "taskGraphContract", from: "A", kind: "TaskGraphContract", acceptedRequired: true},
		{id: "loadedContext", from: "L", kind: "LoadedContext", acceptedRequired: true},
	]
	outputs: [{id: "promotionCandidate", to: "H", kind: "PromotionCandidate", acceptedBy: "P.accepted"}]

	control: {
		invariants: ["L.accepted == true", "changed paths match task graph", "validations passed", "prior accepted states preserved"]
		rejects: ["validation_missing", "changed_path_not_in_graph", "graph_not_preserved", "ready_for_mutation_too_early"]
		acceptance: ["observed diff is declared", "validations passed", "readyForExport == true", "len(ambiguity) == 0"]
	}
}
