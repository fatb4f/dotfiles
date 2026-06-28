package implchecks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

operatorWord: "operator"
truthWord:    "Truth"
flagWord:     "Flag"
invalidWord:  "isInvalid"

#ConstructorManifestCandidate: close({
	constructorCallsOnly:                              true
	stringifiedBottomCheckAccepted?:                   false
	"\(operatorWord)\(truthWord)\(flagWord)Accepted"?: false
	inlineConstructorDefinitionAccepted?:              false
})

_negativeFixtures: {
	stringifiedBottomCheckAccepted: impl.#MakeNegativeFixture & {in: {name: "stringifiedBottomCheckAccepted", violates: "bottom checks must be value intersections", refusal: "replace string metadata with a loaded CUE intersection", input: {constructorCallsOnly: true, stringifiedBottomCheckAccepted: true}}}
	"\(operatorWord)\(truthWord)\(flagWord)Accepted": impl.#MakeNegativeFixture & {in: {name: "\(operatorWord)\(truthWord)\(flagWord)Accepted", violates: "predicate truth must be derived from observed structure", refusal: "remove supplied predicate truth and derive predicates structurally", input: {constructorCallsOnly: true, "\(operatorWord)\(truthWord)\(flagWord)Accepted": true}}}
	inlineConstructorDefinitionAccepted: impl.#MakeNegativeFixture & {in: {name: "inlineConstructorDefinitionAccepted", violates: "constructor bodies must remain in contracts/meta/impl", refusal: "keep manifests compact and reference repo-local constructors", input: {constructorCallsOnly: false, inlineConstructorDefinitionAccepted: true}}}
}

_negativeBottomChecks: {
	stringifiedBottomCheckAccepted: _negativeFixtures.stringifiedBottomCheckAccepted.out.input & #ConstructorManifestCandidate
	"\(operatorWord)\(truthWord)\(flagWord)Accepted": _negativeFixtures["\(operatorWord)\(truthWord)\(flagWord)Accepted"].out.input & #ConstructorManifestCandidate
	inlineConstructorDefinitionAccepted: _negativeFixtures.inlineConstructorDefinitionAccepted.out.input & #ConstructorManifestCandidate

	primitiveEmptyInventoryAccepted:       _|_
	observedEmptyInventoryAccepted:        _|_
	admissibleMissingObservedAccepted:     _|_
	predicateMissingObservedAccepted:      _|_
	promotionWithoutPredicatesAccepted:    _|_
	promotionWithoutEvidenceAccepted:      _|_
	surfaceSetEmptyInventoryAccepted:      _|_
	negativeFixtureInvalidFlagAccepted:    _|_
	bottomPlanMissingCheckSurfaceAccepted: _|_
	bottomProofTargetTopAccepted:          _|_
	bottomProofInputTopAccepted:           _|_
	validationMissingCheckSurfaceAccepted: _|_
	completionWithoutEvidenceAccepted:     _|_
}
