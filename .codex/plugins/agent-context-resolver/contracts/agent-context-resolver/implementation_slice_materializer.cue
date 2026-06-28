package agentcontextresolver

#RawImplementationSliceIssue: close({
	number: int & >0
	title:  string & !=""
	body:   string & !=""
	state?: string & !=""
	labels?: [...]
})

#ImplementationSliceValidationCommand: close({
	id:   string & !=""
	argv: [string & !="", ...string & !=""]
	expect?: "pass" | "fail"
	reasonClass?: "structural_bottom" | "missing_selector" | "load_error" | "syntax_error" | "tool_failure"
})

#ParsedImplementationSliceIssue: close({
	number?: int & >0
	title?:  string & !=""
	sourceTemplateRef?: string & !=""
	contract: {
		path:    string & !=""
		package: string & !=""
		slice:   string & !=""
		authority: {
			owns:       [string & !="", ...string & !=""]
			doesNotOwn: [string & !="", ...string & !=""]
		}
	}
	primitives: [...string & !=""]
	surfaces: {
		admissible: [...string & !=""]
		observed: [...string & !=""]
		candidates: [...string & !=""]
		fixtures: [...string & !=""]
		checks: [string & !="", ...string & !=""]
		publicExports: [string & !="", ...string & !=""]
	}
	filePlan: [...{path: string & !="", purpose: string & !=""}]
	evalSurfaces: [...string & !=""]
	fixtures: [...string & !=""]
	checks: [...string & !=""]
	validation: {
		positive: [#ImplementationSliceValidationCommand, ...#ImplementationSliceValidationCommand]
		negative: [...#ImplementationSliceValidationCommand & {expect: "fail", reasonClass: "structural_bottom" | "missing_selector" | "load_error" | "syntax_error" | "tool_failure"}]
	}
	gates: [...string & !=""]
})

#ImplementationSliceIssue: close({
	kind: "cueImplementationSlice"
	contract: {
		path:    string & !=""
		package: string & !=""
		slice:   string & !=""
		authority: {
			owns:       [string & !="", ...string & !=""]
			doesNotOwn: [string & !="", ...string & !=""]
		}
		boundaries: {...}
	}
	surfaces: {
		admissible: [...string & !=""]
		observed: [...string & !=""]
		candidates: [...string & !=""]
		fixtures: [...string & !=""]
		checks: [string & !="", ...string & !=""]
		publicExports: [string & !="", ...string & !=""]
	}
	constraints: {...}
	acceptanceCriteria: {...}
})

#ImplementationSliceMaterialization: close({
	issueRef:          string & !=""
	parsedRef:         string & !=""
	loadedRef:         string & !=""
	sourceTemplateRef: string & !=""
	evalObligationsRef: string & !=""
	parsedIssue: #ParsedImplementationSliceIssue
	loadedIssue: #ImplementationSliceIssue
	authority: {cue: true, parser: false, runner: false, generated: false}
})

#RawOrParsedIssueMaterialization: {
	issueRef?: string
	parsedRef?: string
	loadedRef?: string
	evalObligationsRef?: string
	parsedIssue?: {...}
	loadedIssue?: {...}
	evalPlan?: {...}
	runnerPlan?: {...}
	predicates?: {...}
}

#IssueMaterializationPredicates: close({
	input: #RawOrParsedIssueMaterialization
	requiresParsedIssue: bool
	requiresLoadedIssue: bool
	evalPlanDerivedFromLoadedIssue: bool
	runnerPlanDerivedFromEvalPlan: bool
	expectedFailureClassified: bool
	negativeSelectorsResolve: bool
})

#IssueMaterializationCandidate: _candidate=(close({
	issueRef?: string
	parsedRef?: string
	loadedRef?: string
	evalObligationsRef?: string
	parsedIssue?: {...}
	loadedIssue?: {...}
	evalPlan?: {...}
	runnerPlan?: {...}
	predicates: #IssueMaterializationPredicates & {input: {issueRef: _candidate.issueRef | *"issue-44"}}
}) & {
	if !_candidate.predicates.requiresParsedIssue {_missingParsedIssue: true & false}
	if !_candidate.predicates.requiresLoadedIssue {_missingLoadedIssue: true & false}
	if !_candidate.predicates.evalPlanDerivedFromLoadedIssue {_staticEvalPlan: true & false}
	if !_candidate.predicates.runnerPlanDerivedFromEvalPlan {_unlinkedRunnerPlan: true & false}
	if !_candidate.predicates.expectedFailureClassified {_unclassifiedExpectedFailure: true & false}
	if !_candidate.predicates.negativeSelectorsResolve {_unresolvedNegativeSelector: true & false}
})

#CUEImplementationSliceIssue: #ImplementationSliceIssue

externalParsedImplementationSliceIssue?: #ParsedImplementationSliceIssue

#IssueMaterializationFromParsed: close({
	parsed: #ParsedImplementationSliceIssue
	loaded: #ImplementationSliceIssue & {
		kind: "cueImplementationSlice"
		contract: {
			path:    parsed.contract.path
			package: parsed.contract.package
			slice:   parsed.contract.slice
			authority: {owns: parsed.contract.authority.owns, doesNotOwn: parsed.contract.authority.doesNotOwn}
			boundaries: {
				adapters: {authority: false, role: "observe/project/execute declared behavior only"}
				generated: {authority: false, role: "downstream projection or materialized evidence only"}
				runtime: {authority: false, role: "external substrate, not contract truth"}
			}
		}
		surfaces: parsed.surfaces
		constraints: {
			noVocabularyOnlyPatch: true
			noDiagnosticBooleanAuthority: true
			noReviewMetadataAsProof: true
			noStringifiedEvalExpressions: true
			noGeneratedArtifactAsAuthority: true
			noAdapterLocalPolicyAuthority: true
			noShellOnlySemanticValidation: true
			noSidePackageSprawl: true
		}
		acceptanceCriteria: {
			rootQuestionAnsweredBeforeImplementation: true
			authorityBoundaryDeclared: true
			primitiveModelDeclared: true
			admissibleSurfaceDeclared: true
			validFixtureExports: true
			publicEvalSurfaceExports: true
			negativeFixturesBottomIfPresent: true
			forbiddenAttractorSearchPasses: true
			validationCommandsReported: true
		}
	}
	let _parsed = parsed
	let _loaded = loaded
	materialization: #ImplementationSliceMaterialization & {
		issueRef:          "issue-\(_parsed.number | 44)"
		parsedRef:         "generated/agent-context-resolver/issues/\(_parsed.number | 44)/parsed.issue.json"
		loadedRef:         "generated/agent-context-resolver/issues/\(_parsed.number | 44)/loaded.issue.json"
		sourceTemplateRef: _parsed.sourceTemplateRef | ".github/ISSUE_TEMPLATE/cue-implementation-slice.md"
		evalObligationsRef: "generated/agent-context-resolver/issues/\(_parsed.number | 44)/eval-obligations.json"
		parsedIssue:       _parsed
		loadedIssue:       _loaded
		authority: {cue: true, parser: false, runner: false, generated: false}
	}
})
