package impl

#NonEmptyString: string & !=""
#NonEmptyStringList: [...#NonEmptyString] & [_, ...]

_defaultForbiddenPattern: "[i]nlineConstructorDefinition: true|[g]eneratedArtifactsAreAuthority: true|== *_\\|_"

#PrimitiveSpec: close({
	name:           #NonEmptyString
	role:           #NonEmptyString
	requiredFields: #NonEmptyStringList
	constraints:    [...#NonEmptyString] | *[]
	closed:         bool | *true
})

#PrimitiveDescriptor: close({
	kind:           "primitive-spec"
	name:           #NonEmptyString
	role:           #NonEmptyString
	requiredFields: [...#NonEmptyString]
	constraints:    [...#NonEmptyString]
	closed:         bool
})

#MakePrimitive: {
	in: #PrimitiveSpec
	out: #PrimitiveDescriptor & {
		kind:           "primitive-spec"
		name:           in.name
		role:           in.role
		requiredFields: in.requiredFields
		constraints:    in.constraints
		closed:         in.closed
	}
}

#ObservedSurfaceSpec: close({
	name:     #NonEmptyString
	target:   #NonEmptyString
	paths:    #NonEmptyStringList
	evidence: #NonEmptyString
})

#ObservedSurfaceDescriptor: close({
	kind:     "observed-surface"
	name:     #NonEmptyString
	target:   #NonEmptyString
	paths:    #NonEmptyStringList
	evidence: #NonEmptyString
})

#MakeObservedSurface: {
	in: #ObservedSurfaceSpec
	out: #ObservedSurfaceDescriptor & {
		kind:     "observed-surface"
		name:     in.name
		target:   in.target
		paths:    in.paths
		evidence: in.evidence
	}
}

#AdmissibleSurfaceSpec: close({
	name:    #NonEmptyString
	target:  #NonEmptyString
	allows:  #NonEmptyStringList
	forbids: #NonEmptyStringList
})

#AdmissibleSurfaceDescriptor: close({
	kind:    "admissible-surface"
	name:    #NonEmptyString
	target:  #NonEmptyString
	allows:  #NonEmptyStringList
	forbids: #NonEmptyStringList
})

#MakeAdmissibleSurface: {
	in: #AdmissibleSurfaceSpec
	out: #AdmissibleSurfaceDescriptor & {
		kind:    "admissible-surface"
		name:    in.name
		target:  in.target
		allows:  in.allows
		forbids: in.forbids
	}
}

#Predicate: close({
	id:   #NonEmptyString
	rule: #NonEmptyString
})

#PredicateSetSpec: close({
	name:       #NonEmptyString
	predicates: [...#Predicate] & [_, ...]
})

#PredicateSetDescriptor: close({
	kind:       "predicate-set"
	name:       #NonEmptyString
	predicates: [...#Predicate] & [_, ...]
})

#MakePredicateSet: {
	in: #PredicateSetSpec
	out: #PredicateSetDescriptor & {
		kind:       "predicate-set"
		name:       in.name
		predicates: in.predicates
	}
}

#PromotionCandidateSpec: close({
	name:     #NonEmptyString
	from:     #NonEmptyString
	to:       #NonEmptyString
	intent:   #NonEmptyStringList
	nonGoals: #NonEmptyStringList
})

#PromotionCandidateDescriptor: close({
	kind:     "promotion-candidate"
	name:     #NonEmptyString
	from:     #NonEmptyString
	to:       #NonEmptyString
	intent:   #NonEmptyStringList
	nonGoals: #NonEmptyStringList
})

#MakePromotionCandidate: {
	in: #PromotionCandidateSpec
	out: #PromotionCandidateDescriptor & {
		kind:     "promotion-candidate"
		name:     in.name
		from:     in.from
		to:       in.to
		intent:   in.intent
		nonGoals: in.nonGoals
	}
}

#PublicExportKind: "manifest" | "slice" | "validation-plan" | "completion-report" | "report"

#PublicExportSpec: close({
	name:      #NonEmptyString
	expr:      #NonEmptyString
	kind:      #PublicExportKind
	stability: "stable" | "experimental" | "internal" | *"stable"
	consumers: [...#NonEmptyString] | *[]
})

#PublicExportDescriptor: close({
	kind:      #PublicExportKind
	name:      #NonEmptyString
	expr:      #NonEmptyString
	stability: "stable" | "experimental" | "internal"
	consumers: [...#NonEmptyString]
})

#MakePublicExport: {
	in: #PublicExportSpec
	out: #PublicExportDescriptor & {
		kind:      in.kind
		name:      in.name
		expr:      in.expr
		stability: in.stability
		consumers: in.consumers
	}
}

#AuthorityBoundarySpec: close({
	name:        #NonEmptyString
	authority:   #NonEmptyStringList
	evidence:    #NonEmptyStringList
	projections: #NonEmptyStringList
	forbidden:   #NonEmptyStringList
})

#AuthorityBoundaryDescriptor: close({
	kind:        "authority-boundary"
	name:        #NonEmptyString
	authority:   #NonEmptyStringList
	evidence:    #NonEmptyStringList
	projections: #NonEmptyStringList
	forbidden:   #NonEmptyStringList
})

#MakeAuthorityBoundary: {
	in: #AuthorityBoundarySpec
	out: #AuthorityBoundaryDescriptor & {
		kind:        "authority-boundary"
		name:        in.name
		authority:   in.authority
		evidence:    in.evidence
		projections: in.projections
		forbidden:   in.forbidden
	}
}

#SurfaceSetSpec: close({
	admissible:   #NonEmptyStringList
	observed:     #NonEmptyStringList
	candidates:   #NonEmptyStringList
	fixtures:     #NonEmptyStringList
	checks:       #NonEmptyStringList
	publicExports: #NonEmptyStringList
})

#SurfaceSetDescriptor: close({
	kind:          "surface-set"
	admissible:    #NonEmptyStringList
	observed:      #NonEmptyStringList
	candidates:    #NonEmptyStringList
	fixtures:      #NonEmptyStringList
	checks:        #NonEmptyStringList
	publicExports: #NonEmptyStringList
})

#MakeSurfaceSet: {
	in: #SurfaceSetSpec
	out: #SurfaceSetDescriptor & {
		kind:          "surface-set"
		admissible:    in.admissible
		observed:      in.observed
		candidates:    in.candidates
		fixtures:      in.fixtures
		checks:        in.checks
		publicExports: in.publicExports
	}
}

#FixtureClass:
	"authority-inversion" |
	"surface-escape" |
	"adapter-bypass" |
	"closedness-violation" |
	"required-field-missing" |
	"invalid-public-export" |
	"contract-violation"

#NegativeFixtureSpec: close({
	name:     #NonEmptyString
	class:    #FixtureClass | *"contract-violation"
	violates: #NonEmptyString
	refusal:  #NonEmptyString
	input:    {...}
})

#NegativeFixtureDescriptor: close({
	kind:            "negative-fixture"
	id:              string & =~"^negative\\..+"
	class:           #FixtureClass
	violates:        #NonEmptyString
	expectedRefusal: #NonEmptyString
	input:           {...}
	expectedBottom:  true
})

#MakeNegativeFixture: {
	in: #NegativeFixtureSpec
	out: #NegativeFixtureDescriptor & {
		kind:            "negative-fixture"
		id:              "negative.\(in.name)"
		class:           in.class
		violates:        in.violates
		expectedRefusal: in.refusal
		input:           in.input
		expectedBottom:  true
	}
}

#BottomCheckPlanSpec: close({
	name:                 #NonEmptyString
	fixture:              #NonEmptyString
	checkSurface:         #NonEmptyString
	checkFile:            #NonEmptyString
	checkExpression:      #NonEmptyString | *"\(checkSurface).\(name)"
	expectedFailure:      true | *true
	expectedDiagnostic:   #NonEmptyString | *name
	targetBoundByAdapter: true | *true
})

#BottomCheckPlan: close({
	kind:                 "bottom-check-plan"
	name:                 #NonEmptyString
	fixture:              #NonEmptyString
	checkSurface:         #NonEmptyString
	checkFile:            #NonEmptyString
	checkExpression:      #NonEmptyString
	expectedFailure:      true
	expectedDiagnostic:   #NonEmptyString
	targetBoundByAdapter: true
})

#MakeBottomCheckPlan: {
	in: #BottomCheckPlanSpec
	out: #BottomCheckPlan & {
		kind:                 "bottom-check-plan"
		name:                 in.name
		fixture:              in.fixture
		checkSurface:         in.checkSurface
		checkFile:            in.checkFile
		checkExpression:      in.checkExpression
		expectedFailure:      in.expectedFailure
		expectedDiagnostic:   in.expectedDiagnostic
		targetBoundByAdapter: in.targetBoundByAdapter
	}
}

#BottomCheckProofSpec: close({
	checks: #NonEmptyStringList
	cases:  [...#BottomCheckPlan] & [_, ...]
})

#BottomCheckProof: close({
	kind: "bottom-check-proof"
	invariant: close({
		bottomIsInspectableValue: false
		forcedExportFailure:      true
		adapterOwnsAssertion:     true
	})
	checks: #NonEmptyStringList
	cases: [...close({
		name:               #NonEmptyString
		file:               #NonEmptyString
		expr:               #NonEmptyString
		expectedFailure:    true
		expectedDiagnostic: #NonEmptyString
	})] & [_, ...]
})

#MakeBottomCheckProof: {
	in: #BottomCheckProofSpec
	out: #BottomCheckProof & {
		kind: "bottom-check-proof"
		invariant: {
			bottomIsInspectableValue: false
			forcedExportFailure:      true
			adapterOwnsAssertion:     true
		}
		checks: in.checks
		cases: [
			for check in in.cases {
				{
					name:               check.name
					file:               check.checkFile
					expr:               check.checkExpression
					expectedFailure:    check.expectedFailure
					expectedDiagnostic: check.expectedDiagnostic
				}
			},
		]
	}
}

#ForbiddenPatternSpec: close({
	id:      #NonEmptyString
	pattern: #NonEmptyString
	reason:  #NonEmptyString
	scope:   #NonEmptyString
})

#ForbiddenPatternDescriptor: close({
	kind:    "forbidden-pattern"
	id:      #NonEmptyString
	pattern: #NonEmptyString
	reason:  #NonEmptyString
	scope:   #NonEmptyString
})

#MakeForbiddenPattern: {
	in: #ForbiddenPatternSpec
	out: #ForbiddenPatternDescriptor & {
		kind:    "forbidden-pattern"
		id:      in.id
		pattern: in.pattern
		reason:  in.reason
		scope:   in.scope
	}
}

#ValidationPlanSpec: close({
	path:              #NonEmptyString
	positiveExports:   [...#PublicExportDescriptor] & [_, ...]
	bottomChecks:      [...#BottomCheckPlan] | *[]
	forbiddenPatterns: [...#ForbiddenPatternDescriptor] | *[]
})

#ValidationPlan: close({
	kind:     "validation-plan"
	commands: #NonEmptyStringList
})

#MakeValidationPlan: {
	in: #ValidationPlanSpec
	out: #ValidationPlan & {
		kind: "validation-plan"
		commands: [
			"cue vet ./\(in.path)",
			for export in in.positiveExports {
				"cue export ./\(in.path) -e \(export.expr)"
			},
			for check in in.bottomChecks {
				"out=\"$(mktemp)\"; if cue export \(check.checkFile) -e '\(check.checkExpression)' >\"$out\" 2>&1; then false; else rg '\(check.expectedDiagnostic)' \"$out\"; fi"
			},
			for pattern in in.forbiddenPatterns {
				"! rg '\(pattern.pattern)' \(pattern.scope)"
			},
		]
	}
}

#CompletionReportSpec: close({
	primitives:    #NonEmptyStringList
	surfaces:      #NonEmptyStringList
	publicExports: #NonEmptyStringList
	fixtures:      #NonEmptyStringList
	checks:        #NonEmptyStringList
	commands:      #NonEmptyStringList
	evidence:      #NonEmptyStringList
})

#CompletionReportContract: close({
	kind:             "completion-report-contract"
	requiredSections: #NonEmptyStringList
	expected: close({
		primitives:    #NonEmptyStringList
		surfaces:      #NonEmptyStringList
		publicExports: #NonEmptyStringList
		fixtures:      #NonEmptyStringList
		checks:        #NonEmptyStringList
		commands:      #NonEmptyStringList
		evidence:      #NonEmptyStringList
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
			"public exports implemented",
			"fixtures implemented",
			"bottom checks implemented",
			"commands run",
			"evidence",
			"final result",
		]
		expected: {
			primitives:    in.primitives
			surfaces:      in.surfaces
			publicExports: in.publicExports
			fixtures:      in.fixtures
			checks:        in.checks
			commands:      in.commands
			evidence:      in.evidence
		}
	}
}
