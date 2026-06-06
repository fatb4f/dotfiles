package p_perform

goodPromote: #PromotePhase & {
	input: {
		taskGraphContract: {id: "taskGraph.good"}
		loadedContext: {id: "loadedContext.good"}
		loadedContextAccepted: true
	}
	output: {
		id: "promotion.good"
		taskGraphContract: {id: "taskGraph.good"}
		taskGraphContractAccepted: true
		loadedContext: {id: "loadedContext.good"}
		loadedContextAccepted: true
		changedPaths: []
		validations: [
			{id: "cue-vet", command: "cue vet ./cue/...", passed: true, evidence: "validation.cue-vet"},
		]
		agent: {role: "codex-worktree"}
		runner: {role: "apply-patch"}
		ambiguity: []
	}
}

negativeValidationMissing: {
	id: "promotion.bad.validation_missing"
	validations: []
	validationsPassed: false
	ambiguity: ["validation_missing"]
}

negativeChangedPathNotInGraph: {
	id: "promotion.bad.changed_path"
	changedPaths: [{path: "unowned/path", taskID: "unknown", declaredIn: "none"}]
	noUndeclaredMutation:       false
	changedPathsMatchTaskGraph: false
	ambiguity: ["changed_path_not_in_graph"]
}

negativeGraphNotPreserved: {
	id:                      "promotion.bad.graph_not_preserved"
	priorAcceptedStatesHeld: false
	ambiguity: ["graph_not_preserved"]
}

negativeReadyForMutationTooEarly: {
	id:                       "promotion.bad.ready_for_mutation"
	readyForMutationWasFalse: false
	ambiguity: ["ready_for_mutation_too_early"]
}
