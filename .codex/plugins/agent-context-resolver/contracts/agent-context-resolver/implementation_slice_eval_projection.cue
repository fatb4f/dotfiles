package agentcontextresolver

#ImplementationSliceEvalObligations: close({
	loadedIssue: #ImplementationSliceIssue
	materialization: #ImplementationSliceMaterialization

	positive: [
		{id: "vet", argv: ["cue", "vet", "./\(loadedIssue.contract.path)"]},
		for e in loadedIssue.surfaces.publicExports {
			{id: "export.\(e)", argv: ["cue", "export", "./\(loadedIssue.contract.path)", "-e", e]}
		},
	]

	negative: [
		for c in loadedIssue.surfaces.checks {
			{id: "bottom.\(c)", selector: c, argv: ["cue", "export", "./\(loadedIssue.contract.path)", "-e", c], reasonClass: "structural_bottom"}
		},
	]

	forbiddenAttractors: [{id: "forbidden-attractor-search", argv: ["true"], expect: "fail", reasonClass: "structural_bottom"}]

	generated: [
		"generated/agent-context-resolver/issues/\(materialization.parsedIssue.number | 44)/parsed.issue.json",
		"generated/agent-context-resolver/issues/\(materialization.parsedIssue.number | 44)/loaded.issue.json",
		"generated/agent-context-resolver/issues/\(materialization.parsedIssue.number | 44)/eval-plan.json",
		"generated/agent-context-resolver/issues/\(materialization.parsedIssue.number | 44)/runner-plan.json",
		"generated/agent-context-resolver/issues/\(materialization.parsedIssue.number | 44)/feedback.json",
	]
})

#ImplementationSliceEvalPlan: close({
	schema: "agent-context-resolver.implementation-slice-eval-plan.v1"
	issueID: string & !=""
	sourceIssueRef: string & !=""
	loadedIssueRef: string & !=""
	commands: [#ImplementationSliceEvalCommand, ...#ImplementationSliceEvalCommand]
})

#ImplementationSliceEvalCommand: close({
	id: string & !=""
	argv: [string & !="", ...string & !=""]
	expect: "pass" | "fail"
	reasonClass?: "structural_bottom" | "missing_selector" | "load_error" | "syntax_error" | "tool_failure"
	selector?: string & !=""
})

#ImplementationSliceRunnerPlan: close({
	schema: "agent-context-resolver.implementation-slice-runner-plan.v1"
	issueID: string & !=""
	commands: [#ImplementationSliceRunnerCommand, ...#ImplementationSliceRunnerCommand]
	expectations: {failuresClassified: true, anyNonZeroAlone: false}
	evidenceShape: "#ClassifiedRunnerResult"
	sourceEvalPlan: #ImplementationSliceEvalPlan
})

#ImplementationSliceRunnerCommand: close({
	id: string & !=""
	sourceEvalID: string & !=""
	command: [string & !="", ...string & !=""]
	expect: "pass" | "fail"
	reasonClass?: "structural_bottom"
	stderrMustContain?: ["_|_", ...string]
	selector?: string & !=""
})

#ImplementationSlicePlanProjection: close({
	materialization: #ImplementationSliceMaterialization
	let _materialization = materialization
	obligations: #ImplementationSliceEvalObligations & {loadedIssue: _materialization.loadedIssue, materialization: _materialization}
	evalPlan: #ImplementationSliceEvalPlan & {
		issueID: _materialization.issueRef
		sourceIssueRef: _materialization.parsedRef
		loadedIssueRef: _materialization.loadedRef
		commands: [
			for c in obligations.positive {
				{id: c.id, argv: c.argv, expect: "pass"}
			},
			for c in obligations.negative {
				{id: c.id, argv: c.argv, expect: "fail", reasonClass: c.reasonClass, selector: c.selector}
			},
		]
	}
	runnerPlan: #ImplementationSliceRunnerPlan & {
		issueID: _materialization.issueRef
		sourceEvalPlan: evalPlan
		commands: [
			for c in evalPlan.commands {
				{
					id: c.id
					sourceEvalID: c.id
					command: c.argv
					expect: c.expect
					if c.expect == "fail" {
						reasonClass: c.reasonClass
						stderrMustContain: ["_|_"]
						selector: c.selector
					}
				}
			},
		]
	}
})
