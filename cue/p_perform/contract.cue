package p_perform

#ExecutedTask: {
	id:                      string
	acceptedBeforeExecution: true
	runner:                  string
	evidencePath?:           string
}

#RunManifest: {
	id: string

	executedTasks: [...#ExecutedTask]
	executedOnlyAcceptedTasks: bool

	agent: {
		role:          "semantic-runner"
		proposedFill:  bool
		ownsPolicy:    false
		calledRawFill: false
	}

	runner: {
		role:           "ralph-runner" | "hookrail-evidence" | "adapter-runner"
		validatedFill:  bool
		calledTaskFill: bool
		ownsPolicy:     false
	}

	execution: {
		sourcePackage:             string
		terminated:                bool
		completionEvidencePresent: bool
	}

	ambiguity: [...string]
}

#PerformPhase: {
	"@context": "https://fatb4f.dev/ns/ralph/perform/v0"
	"@id":      "ralph:P"
	"@type":    "ralph:PhaseNode"

	id:   "P"
	name: "perform"

	input: {
		taskGraphContract: _
		validationFacts:   _
		legitimized:       true
	}

	output: #RunManifest

	accepted: output.executedOnlyAcceptedTasks == true && output.runner.calledTaskFill == true && output.agent.calledRawFill == false && len(output.ambiguity) == 0

	control: {
		invariants: [
			"P executes only what L legitimized",
			"P does not authorize",
			"P does not persist durable memory",
			"agent never calls raw fill",
		]
	}
}
