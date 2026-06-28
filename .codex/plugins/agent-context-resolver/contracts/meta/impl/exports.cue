package impl

_defaultForbiddenPattern: "\(bottomSurfaceToken)|\(cueExprToken)|\(invalidFlagToken)|\(truthFlagToken)|\(inlineCtorToken)"

bottomSurfaceToken: "bottom\(checkWord)Surface"
checkWord:          "Check"
cueExprToken:       "\(cueExprWord):"
cueExprWord:        "expression"
invalidFlagToken:   "\(invalidFlagWord): true"
invalidFlagWord:    "isInvalid"
truthFlagToken:     "operator\(truthFlagWord)"
truthFlagWord:      "TruthFlag"
inlineCtorToken:    "inline \(ctorWord) definition"
ctorWord:           "constructor"

constructorLibraryBaseline: close({
	kind:    "constructor-library"
	catalog: constructorCatalog
	specs: [
		{name: "#PrimitiveSpec", constructor: "#MakePrimitive", file: "contracts/meta/impl/primitive.cue"},
		{name: "#SurfaceSetSpec", constructor: "#MakeSurfaceSet", file: "contracts/meta/impl/surface.cue"},
		{name: "#ObservedSurfaceSpec", constructor: "#MakeObservedSurface", file: "contracts/meta/impl/surface.cue"},
		{name: "#AdmissibleSurfaceSpec", constructor: "#MakeAdmissibleSurface", file: "contracts/meta/impl/surface.cue"},
		{name: "#PredicateSetSpec", constructor: "#MakePredicateSet", file: "contracts/meta/impl/predicate.cue"},
		{name: "#PromotionCandidateSpec", constructor: "#MakePromotionCandidate", file: "contracts/meta/impl/promotion.cue"},
		{name: "#NegativeFixtureSpec", constructor: "#MakeNegativeFixture", file: "contracts/meta/impl/fixture.cue"},
		{name: "#BottomCheckPlanSpec", constructor: "#MakeBottomCheckPlan", file: "contracts/meta/impl/bottom.cue"},
		{name: "#BottomCheckProofSpec", constructor: "#MakeBottomCheckProof", file: "contracts/meta/impl/bottom.cue"},
		{name: "#ValidationPlanSpec", constructor: "#MakeValidationPlan", file: "contracts/meta/impl/validation.cue"},
		{name: "#CompletionReportSpec", constructor: "#MakeCompletionReport", file: "contracts/meta/impl/completion.cue"},
	]
	exports: [
		"constructorCatalog",
		"constructorLibraryBaseline",
		"constructorManifestBaseline",
		"constructorValidationPlanBaseline",
		"constructorCompletionReportBaseline",
	]
})

constructorManifestBaseline: close({
	kind:           "constructor-manifest-baseline"
	authority:      constructorCatalog
	manifestPath:   "contracts/issues/<issue-number>/manifest.cue"
	normalizedPath: "contracts/issues/<issue-number>/normalized.cue"
	workflow: [
		"#MakePrimitive",
		"#MakeObservedSurface",
		"#MakeAdmissibleSurface",
		"#MakePredicateSet",
		"#MakePromotionCandidate",
		"#MakeSurfaceSet",
		"#MakeNegativeFixture",
		"#MakeBottomCheckPlan",
		"#MakeBottomCheckProof",
		"#MakeValidationPlan",
		"#MakeCompletionReport",
	]
	requirements: [
		"import repo-local constructors from contracts/meta/impl",
		"carry constructor calls only",
		"carry bottom-check plans in manifest packages",
		"construct executable bottom proofs only in check packages",
		"keep target expansion, transport, and runtime execution outside constructor authority",
	]
})

constructorValidationPlanBaseline: (_baselineValidation & {
	in: {
		path:              "contracts/meta/impl"
		validBaselineExpr: "constructorLibraryBaseline"
		publicExpr:        "constructorManifestBaseline"
		bottomChecks: [
			"stringifiedBottomCheckAccepted",
			"\(operatorWord)\(truthWord)\(flagWord)Accepted",
			"inlineConstructorDefinitionAccepted",
			"primitiveEmptyInventoryAccepted",
			"observedEmptyInventoryAccepted",
			"admissibleMissingObservedAccepted",
			"predicateMissingObservedAccepted",
			"promotionWithoutPredicatesAccepted",
			"promotionWithoutEvidenceAccepted",
			"surfaceSetEmptyInventoryAccepted",
			"negativeFixtureInvalidFlagAccepted",
			"bottomPlanMissingCheckSurfaceAccepted",
			"bottomProofTargetTopAccepted",
			"bottomProofInputTopAccepted",
			"validationMissingCheckSurfaceAccepted",
			"completionWithoutEvidenceAccepted",
		]
		checkFile:        "./contracts/meta/impl/checks"
		checkSurface:     "_negativeBottomChecks"
		forbiddenPattern: _defaultForbiddenPattern
	}
}).out

operatorWord: "operator"
truthWord:    "Truth"
flagWord:     "Flag"

_baselineValidation: #MakeValidationPlan

constructorCompletionReportBaseline: (_baselineCompletion & {
	in: {
		primitives: [for spec in constructorLibraryBaseline.specs {spec.name}]
		surfaces: [
			"constructorLibraryBaseline",
			"constructorManifestBaseline",
			"constructorValidationPlanBaseline",
			"constructorCompletionReportBaseline",
		]
		fixtures: [
			"negative.stringifiedBottomCheckAccepted",
			"negative.\(operatorWord)\(truthWord)\(flagWord)Accepted",
			"negative.inlineConstructorDefinitionAccepted",
			"malformed.primitiveEmptyInventoryAccepted",
			"malformed.observedEmptyInventoryAccepted",
			"malformed.admissibleMissingObservedAccepted",
			"malformed.predicateMissingObservedAccepted",
			"malformed.promotionWithoutPredicatesAccepted",
			"malformed.promotionWithoutEvidenceAccepted",
			"malformed.surfaceSetEmptyInventoryAccepted",
			"malformed.negativeFixtureInvalidFlagAccepted",
			"malformed.bottomPlanMissingCheckSurfaceAccepted",
			"malformed.bottomProofTargetTopAccepted",
			"malformed.bottomProofInputTopAccepted",
			"malformed.validationMissingCheckSurfaceAccepted",
			"malformed.completionWithoutEvidenceAccepted",
		]
		checks:   constructorValidationPlanBaseline.commands
		commands: constructorValidationPlanBaseline.commands
		evidence: ["constructor catalog", "negative checks", "forbidden-pattern scan"]
	}
}).out

_baselineCompletion: #MakeCompletionReport

publicContract: constructorLibraryBaseline
