package agentcontextresolver

#ClassifiedRunnerResult: close({
	commandID: string & !=""
	status: "pass" | "fail"
	expected: "pass" | "fail"
	actual: {
		exitCode: int
		stderr?: string
		stdout?: string
	}
	reasonClass: "none" | "structural_bottom" | "missing_selector" | "load_error" | "syntax_error" | "tool_failure" | "expectation_mismatch"

	if expected == "fail" {
		if reasonClass != "structural_bottom" {
			_wrongFailure: _|_
		}
	}
})

implementationSliceFeedbackShape: {
	schema: "agent-context-resolver.implementation-slice-feedback.v1"
	issueID: "issue-44"
	results: []
}
