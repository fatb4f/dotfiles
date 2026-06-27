package workflow

#NonEmptyString: string & !=""

#Named: {
	name: #NonEmptyString
	...
}

#DotfilesPrimitiveSpec: #Named & {
	role: #NonEmptyString
	requiredFields: [...#NonEmptyString]
	constraints: [...#NonEmptyString]
	closed: bool | *true
	...
}

#ObservedSurfaceSpec: #Named & {
	target: #NonEmptyString
	paths: [...#NonEmptyString]
	evidence: #NonEmptyString
	...
}

#AdmissibleSurfaceSpec: #Named & {
	target: #NonEmptyString
	allows: [...#NonEmptyString]
	forbids: [...#NonEmptyString]
	...
}

#Predicate: {
	id: #NonEmptyString
	rule: #NonEmptyString
}

#PredicateSetSpec: #Named & {
	predicates: [...#Predicate]
	...
}

#PromotionCandidateSpec: #Named & {
	from: #NonEmptyString
	to: #NonEmptyString
	intent: [...#NonEmptyString]
	nonGoals: [...#NonEmptyString]
	...
}

#SurfaceSetSpec: {
	admissible: [...#NonEmptyString]
	observed: [...#NonEmptyString]
	candidates: [...#NonEmptyString]
	fixtures: [...#NonEmptyString]
	checks: [...#NonEmptyString]
	publicExports: [...#NonEmptyString]
	...
}

#NegativeFixtureSpec: #Named & {
	input: _
	expect: "bottom"
	reason: #NonEmptyString
	...
}

#BottomCheckPlanSpec: #Named & {
	fixture: #NonEmptyString
	checkSurface: #NonEmptyString
	...
}

#BottomCheckProofSpec: {
	in: {
		name: #NonEmptyString
		input: {
			evidence: #NonEmptyString
			value: _
		}
		target: {
			name: #NonEmptyString
			contract: {
				evidence: #NonEmptyString
				value: _
			}
		}
	}
	out: {
		name: in.name
		input: in.input
		target: in.target
		kind: "bottom-check-proof"
	}
}

#ValidationPlanSpec: #Named & {
	commands: [...#NonEmptyString]
	...
}

#CompletionReportSpec: #Named & {
	sections: [...#NonEmptyString]
	...
}

#MakeDotfilesPrimitive: {
	in: #DotfilesPrimitiveSpec
	out: in & {kind: "dotfiles-primitive"}
}

#MakeObservedSurface: {
	in: #ObservedSurfaceSpec
	out: in & {kind: "observed-surface"}
}

#MakeAdmissibleSurface: {
	in: #AdmissibleSurfaceSpec
	out: in & {kind: "admissible-surface"}
}

#MakePredicateSet: {
	in: #PredicateSetSpec
	out: in & {kind: "predicate-set"}
}

#MakePromotionCandidate: {
	in: #PromotionCandidateSpec
	out: in & {kind: "promotion-candidate"}
}

#MakeSurfaceSet: {
	in: #SurfaceSetSpec
	out: in & {kind: "surface-set"}
}

#MakeNegativeFixture: {
	in: #NegativeFixtureSpec
	out: in & {kind: "negative-fixture"}
}

#MakeBottomCheckPlan: {
	in: #BottomCheckPlanSpec
	out: in & {kind: "bottom-check-plan"}
}

#MakeBottomCheckProof: #BottomCheckProofSpec

#MakeValidationPlan: {
	in: #ValidationPlanSpec
	out: in & {kind: "validation-plan"}
}

#MakeCompletionReport: {
	in: #CompletionReportSpec
	out: in & {kind: "completion-report"}
}
