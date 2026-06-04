package p_perform

goodPerform: #PerformPhase & {
	input: {taskGraphContract: {id: "taskGraph.good"}, validationFacts: {id: "validation.good"}, legitimized: true}
	output: {
		id: "run.good"
		executedTasks: []
		executedOnlyAcceptedTasks: true
		agent: {proposedFill: true}
		runner: {role: "ralph-runner", validatedFill: true, calledTaskFill: true}
		execution: {sourcePackage: "cuelang.org/go/tools/flow", terminated: true, completionEvidencePresent: true}
		ambiguity: []
	}
}

badRawFill: {
	id: "run.bad.raw_fill"
	executedTasks: []
	executedOnlyAcceptedTasks: false
	agent: {proposedFill: true, calledRawFill: true}
	runner: {role: "ralph-runner", validatedFill: false, calledTaskFill: false}
	execution: {sourcePackage: "cuelang.org/go/tools/flow", terminated: false, completionEvidencePresent: false}
	ambiguity: ["raw_fill_called_by_agent"]
}
