package p_perform

goodPerform: #PerformPhase & {
	input: {flowContract: {id: "flow.good"}, validationFacts: {id: "validation.good"}, legitimized: true}
	output: {
		id: "run.good"
		executedTasks: []
		executedOnlyAcceptedTasks: true
		agent: {proposedFill: true}
		runner: {role: "go-flow-runner", validatedFill: true, calledTaskFill: true}
		flow: {sourcePackage: "cuelang.org/go/tools/flow", terminated: true, finalValueContainsFill: true}
		ambiguity: []
	}
}

badRawFill: #RunManifest & {
	id: "run.bad.raw_fill"
	executedTasks: []
	executedOnlyAcceptedTasks: false
	agent: {proposedFill: true, calledRawFill: true}
	runner: {role: "go-flow-runner", validatedFill: false, calledTaskFill: false}
	flow: {sourcePackage: "cuelang.org/go/tools/flow", terminated: false, finalValueContainsFill: false}
	ambiguity: ["raw_fill_called_by_agent"]
}
