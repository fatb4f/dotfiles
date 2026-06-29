package impl

_defaultForbiddenPattern: "[i]nlineConstructorDefinitions: true|[g]eneratedArtifactsAreAuthority: true"

#PrimitiveSpec: close({
	name: string & !=""
	role: string & !=""
	requiredFields: [...string & !=""] & [_, ...]
	constraints: [...string & !=""] | *[]
	closed: bool | *true
})

#PrimitiveDescriptor: close({
	kind: "primitive-spec"
	name: string & !=""
	role: string & !=""
	requiredFields: [...string & !=""]
	constraints: [...string & !=""]
	closed: bool
})

#MakePrimitive: {
	in: #PrimitiveSpec
	out: #PrimitiveDescriptor & {
		kind: "primitive-spec"
		name: in.name
		role: in.role
		requiredFields: in.requiredFields
		constraints: in.constraints
		closed: in.closed
	}
}

#SurfaceSetSpec: close({
	admissible: [...string & !=""] & [_, ...]
	observed: [...string & !=""] & [_, ...]
	candidates: [...string & !=""] & [_, ...]
	fixtures: [...string & !=""] & [_, ...]
	checks: [...string & !=""] & [_, ...]
	publicExports: [...string & !=""] & [_, ...]
})

#SurfaceSetDescriptor: close({
	kind: "surface-set"
	admissible: [...string & !=""]
	observed: [...string & !=""]
	candidates: [...string & !=""]
	fixtures: [...string & !=""]
	checks: [...string & !=""]
	publicExports: [...string & !=""]
})

#MakeSurfaceSet: {
	in: #SurfaceSetSpec
	out: #SurfaceSetDescriptor & {
		kind: "surface-set"
		admissible: in.admissible
		observed: in.observed
		candidates: in.candidates
		fixtures: in.fixtures
		checks: in.checks
		publicExports: in.publicExports
	}
}

#NegativeFixtureSpec: close({
	name: string & !=""
	violates: string & !=""
	refusal: string & !=""
	input: {...}
	isInvalid?: false
	expression?: false
	inlineConstructorDefinition?: false
	generatedArtifactsAreAuthority?: false
})

#NegativeFixtureDescriptor: close({
	kind: "negative-fixture"
	id: string & =~"^negative\\..+"
	violates: string & !=""
	expectedRefusal: string & !=""
	input: {...}
	expectedBottom: true
})

#MakeNegativeFixture: {
	in: #NegativeFixtureSpec
	out: #NegativeFixtureDescriptor & {
		kind: "negative-fixture"
		id: "negative.\(in.name)"
		violates: in.violates
		expectedRefusal: in.refusal
		input: in.input
		expectedBottom: true
	}
}

#BottomCheckPlanSpec: close({
	name: string & !=""
	fixture: string & !=""
	checkSurface: string & !=""
	checkFile: string & !=""
	targetBoundByAdapter: true | *true
})

#BottomCheckPlan: close({
	kind: "bottom-check-plan"
	name: string & !=""
	fixture: string & !=""
	checkSurface: string & !=""
	checkFile: string & !=""
	targetBoundByAdapter: true
})

#MakeBottomCheckPlan: {
	in: #BottomCheckPlanSpec
	out: #BottomCheckPlan & {
		kind: "bottom-check-plan"
		name: in.name
		fixture: in.fixture
		checkSurface: in.checkSurface
		checkFile: in.checkFile
		targetBoundByAdapter: in.targetBoundByAdapter
	}
}

#ValidationPlanSpec: close({
	path: string & !=""
	validBaselineExpr: string & !=""
	publicExpr: string & !=""
	bottomChecks: [...string & !=""] & [_, ...]
	checkFile: string & !=""
	checkSurface: string & !=""
	forbiddenPattern: string | *_defaultForbiddenPattern
})

#ValidationPlan: close({
	kind: "validation-plan"
	commands: [...string & !=""]
})

#MakeValidationPlan: {
	in: #ValidationPlanSpec
	out: #ValidationPlan & {
		kind: "validation-plan"
		commands: [
			"cue vet ./\(in.path)",
			"cue export ./\(in.path) -e \(in.validBaselineExpr)",
			"cue export ./\(in.path) -e \(in.publicExpr)",
			for c in in.bottomChecks {
				"! cue export \(in.checkFile) -e '\(in.checkSurface).\(c)'"
			},
			"! rg '\(in.forbiddenPattern)' ./\(in.path)",
		]
	}
}

#CompletionReportSpec: close({
	primitives: [...string & !=""] & [_, ...]
	surfaces: [...string & !=""] & [_, ...]
	fixtures: [...string & !=""] & [_, ...]
	checks: [...string & !=""] & [_, ...]
	commands: [...string & !=""] & [_, ...]
	evidence: [...string & !=""] & [_, ...]
})

#CompletionReportContract: close({
	kind: "completion-report-contract"
	requiredSections: [...string & !=""]
	expected: close({
		primitives: [...string & !=""]
		surfaces: [...string & !=""]
		fixtures: [...string & !=""]
		checks: [...string & !=""]
		commands: [...string & !=""]
		evidence: [...string & !=""]
	})
})

#MakeCompletionReport: {
	in: #CompletionReportSpec
	out: #CompletionReportContract & {
		kind: "completion-report-contract"
		requiredSections: [
			"files changed",
			"primitives implemented",
			"surfaces implemented",
			"fixtures implemented",
			"bottom checks implemented",
			"commands run",
			"evidence",
			"final result",
		]
		expected: {
			primitives: in.primitives
			surfaces: in.surfaces
			fixtures: in.fixtures
			checks: in.checks
			commands: in.commands
			evidence: in.evidence
		}
	}
}
