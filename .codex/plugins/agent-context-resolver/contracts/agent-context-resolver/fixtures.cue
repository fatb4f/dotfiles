package agentcontextresolver

baselineImplementationSliceIssue: #ParsedImplementationSliceIssue & {
	number: 44
	title:  "cue: implement agent-context-resolver implementation-slice issue materializer"
	sourceTemplateRef: ".github/ISSUE_TEMPLATE/cue-implementation-slice.md"
	contract: {
		path:    "contracts/agent-context-resolver"
		package: "resolver"
		slice:   "implementation-slice-issue-materializer"
		authority: {
			owns: ["parsed implementation-slice issue shape", "issue materialization candidate/admissible surface"]
			doesNotOwn: ["GitHub API behavior", "Codex/Claude reasoning", "shell process execution"]
		}
	}
	primitives: ["#RawImplementationSliceIssue", "#ParsedImplementationSliceIssue", "#ImplementationSliceMaterialization", "#ImplementationSliceEvalObligations", "#ImplementationSliceEvalPlan", "#ImplementationSliceRunnerPlan", "#ClassifiedRunnerResult", "#IssueMaterializationCandidate"]
	surfaces: {
		admissible: ["#IssueMaterializationCandidate", "#ImplementationSliceMaterialization"]
		observed: ["#RawImplementationSliceIssue"]
		candidates: ["implementationSliceMaterializationReport"]
		fixtures: ["negativeFixtures.routeOnlyPacket", "negativeFixtures.missingContractPath", "negativeFixtures.staticEvalPlan", "negativeFixtures.missingNegativeCheckExpression", "negativeFixtures.anyNonzeroAsPass"]
		checks: ["_negativeBottomChecks.routeOnlyPacket", "_negativeBottomChecks.missingContractPath", "_negativeBottomChecks.staticEvalPlan", "_negativeBottomChecks.missingNegativeCheckExpression", "_negativeBottomChecks.anyNonzeroAsPass"]
		publicExports: ["implementationSliceIssueBaseline", "implementationSliceMaterializationReport", "implementationSliceEvalPlan", "implementationSliceRunnerPlan", "implementationSliceFeedbackShape"]
	}
	filePlan: [
		{path: "contracts/agent-context-resolver/implementation_slice_materializer.cue", purpose: "raw parsed materialized issue primitives and admissible surfaces"},
		{path: "contracts/agent-context-resolver/implementation_slice_eval_projection.cue", purpose: "issue-specific eval obligation eval-plan and runner-plan projections"},
		{path: "contracts/agent-context-resolver/implementation_slice_runner_result.cue", purpose: "classified runner result and wrong-failure rejection surface"},
	]
	evalSurfaces: surfaces.publicExports
	fixtures: surfaces.fixtures
	checks: surfaces.checks
	validation: {
		positive: [{id: "vet", argv: ["cue", "vet", "./contracts/agent-context-resolver"]}]
		negative: [{id: "negative.routeOnlyPacket", argv: ["cue", "export", "./contracts/agent-context-resolver", "-e", "_negativeBottomChecks.routeOnlyPacket"], expect: "fail", reasonClass: "structural_bottom"}]
	}
	gates: ["admit loaded implementation-slice issue materializer"]
}

negativeFixtures: {
	routeOnlyPacket: {violates: "predicates.requiresParsedLoadedIssue", input: {issueRef: "issue-44", predicates: {requiresParsedIssue: false, requiresLoadedIssue: false, evalPlanDerivedFromLoadedIssue: false, runnerPlanDerivedFromEvalPlan: false, expectedFailureClassified: false, negativeSelectorsResolve: false}}}
	missingContractPath: {violates: "predicates.requiresContractPath", input: {issueRef: "issue-44", parsedIssue: baselineImplementationSliceIssue & {contract: {path: ""}}, loadedIssue: implementationSliceLoadedIssue, predicates: {requiresParsedIssue: true, requiresLoadedIssue: true, evalPlanDerivedFromLoadedIssue: true, runnerPlanDerivedFromEvalPlan: true, expectedFailureClassified: true, negativeSelectorsResolve: true}}}
	staticEvalPlan: {violates: "predicates.evalPlanMustDeriveFromLoadedIssue", input: {issueRef: "issue-44", parsedIssue: baselineImplementationSliceIssue, loadedIssue: implementationSliceLoadedIssue, evalPlan: {issueID: "issue-44", sourceIssueRef: "static-fixture"}, predicates: {requiresParsedIssue: true, requiresLoadedIssue: true, evalPlanDerivedFromLoadedIssue: false, runnerPlanDerivedFromEvalPlan: true, expectedFailureClassified: true, negativeSelectorsResolve: true}}}
	missingNegativeCheckExpression: {violates: "predicates.negativeSelectorMustResolve", input: {issueRef: "issue-44", parsedIssue: baselineImplementationSliceIssue, loadedIssue: implementationSliceLoadedIssue, evalPlan: implementationSliceEvalPlan, runnerPlan: implementationSliceRunnerPlan, predicates: {requiresParsedIssue: true, requiresLoadedIssue: true, evalPlanDerivedFromLoadedIssue: true, runnerPlanDerivedFromEvalPlan: true, expectedFailureClassified: true, negativeSelectorsResolve: false}}}
	anyNonzeroAsPass: {violates: "predicates.expectedFailureRequiresReasonClass", input: {issueRef: "issue-44", parsedIssue: baselineImplementationSliceIssue, loadedIssue: implementationSliceLoadedIssue, evalPlan: implementationSliceEvalPlan, runnerPlan: {commands: [{id: "bad.fail", sourceEvalID: "bad.fail", command: ["false"], expect: "fail"}]}, predicates: {requiresParsedIssue: true, requiresLoadedIssue: true, evalPlanDerivedFromLoadedIssue: true, runnerPlanDerivedFromEvalPlan: true, expectedFailureClassified: false, negativeSelectorsResolve: true}}}
}

implementationSliceIssueBaseline: baselineImplementationSliceIssue
implementationSliceLoaded: #IssueMaterializationFromParsed & {parsed: baselineImplementationSliceIssue}
implementationSliceLoadedIssue: implementationSliceLoaded.loaded
implementationSliceMaterializationReport: implementationSliceLoaded.materialization
implementationSliceProjection: #ImplementationSlicePlanProjection & {materialization: implementationSliceMaterializationReport}
implementationSliceEvalPlan: implementationSliceProjection.evalPlan
implementationSliceRunnerPlan: implementationSliceProjection.runnerPlan
