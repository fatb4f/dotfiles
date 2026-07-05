package impl

// Exit-gate layer: assertion witnesses, negative fixtures, and subsumption checks.
#Assertion: close({
	id:          #KebabIdentifier
	mode:        #AssertionMode
	family:      #EvalFamily | *"assertion"
	description: #NonEmptyString

	expected?:        _
	observed?:        _
	invalid?:         _
	proof?:           _
	proofStatus?:     #ProofStatus
	proofExpr?:       #CueSelectorExpr
	noWidening?:      bool
	expectedFailure?: bool
})

#MakeAssertion: {
	in:  #Assertion
	out: #Assertion & in
}

#PositiveFixture: close({
	id:          #KebabIdentifier
	description: #NonEmptyString
	polarity:    "positive"
	_fixtureID:  id

	authority: #ClosedObligationState
	candidate: #ClosedObligationState
	proof:     authority & candidate

	assertion: #Assertion & {
		id:          "positive-\(_fixtureID)"
		mode:        "unifies"
		family:      "assertion"
		description: "Candidate state must unify with authority"
		expected:    authority
		observed:    candidate
		proof:       proof
		proofStatus: "proven"
	}
})

#MakePositiveFixture: {
	in: close({
		id:          #KebabIdentifier
		description: #NonEmptyString
		authority:   #CodexObligationState
		candidate:   #CodexObligationState
	})
	let closedAuthority = (#MakeClosedObligationState & {"in": in.authority}).out
	let closedCandidate = (#MakeClosedObligationState & {"in": in.candidate}).out
	out: #PositiveFixture & {
		id:          in.id
		description: in.description
		polarity:    "positive"
		authority:   closedAuthority
		candidate:   closedCandidate
		proof:       closedAuthority & closedCandidate
		assertion: {
			id:          "positive-\(in.id)"
			mode:        "unifies"
			family:      "assertion"
			description: "Candidate state must unify with authority"
			expected:    closedAuthority
			observed:    closedCandidate
			proof:       closedAuthority & closedCandidate
			proofStatus: "proven"
		}
	}
}

// Exportable negative fixture metadata. This shape intentionally does not contain
// the destructive authority & invalid proof. Use #MakeNegativeFixture for the
// checked fixture/probe binding.
#NegativeFixtureSpec: close({
	id:          #KebabIdentifier
	description: #NonEmptyString
	polarity:    "negative"
	_fixtureID:  id

	authority: #ClosedObligationState
	invalid:   #ClosedObligationState

	assertion: #Assertion & {
		id:              "negative-\(_fixtureID)"
		mode:            "bottoms"
		family:          "negativeFixture"
		description:     "Invalid state must bottom against authority via destructive probe"
		expected:        authority
		invalid:         invalid
		proofStatus:     "requiresDestructiveProbe"
		expectedFailure: true
	}
})

#NegativeFixture:          #NegativeFixtureSpec
#UncheckedNegativeFixture: #NegativeFixtureSpec

#NegativeFixtureProbeSpec: {
	authority: #ClosedObligationState
	invalid:   #ClosedObligationState
	...
}

#NegativeFixtureConflictProbe: #NegativeFixtureProbeSpec & {
	authority: #ClosedObligationState
	invalid:   #ClosedObligationState

	// Deliberate destructive proof surface: bottoms when invalid conflicts with authority.
	proof: authority & invalid
}

#NegativeFixtureProbeBinding: close({
	fixture: #NegativeFixtureSpec
	probe: #NegativeFixtureConflictProbe & {
		authority: fixture.authority
		invalid:   fixture.invalid
	}
})

#NegativeFixtureCheck: #NegativeFixtureProbeBinding

#MakeUncheckedNegativeFixture: {
	in: close({
		id:          #KebabIdentifier
		description: #NonEmptyString
		authority:   #CodexObligationState
		invalid:     #CodexObligationState
	})
	let closedAuthority = (#MakeClosedObligationState & {"in": in.authority}).out
	let closedInvalid = (#MakeClosedObligationState & {"in": in.invalid}).out
	out: #NegativeFixtureSpec & {
		id:          in.id
		description: in.description
		polarity:    "negative"
		authority:   closedAuthority
		invalid:     closedInvalid
		assertion: {
			id:              "negative-\(in.id)"
			mode:            "bottoms"
			family:          "negativeFixture"
			description:     "Invalid state must bottom against authority via destructive probe"
			expected:        closedAuthority
			invalid:         closedInvalid
			proofStatus:     "requiresDestructiveProbe"
			expectedFailure: true
		}
	}
}

#MakeNegativeFixtureSpec: #MakeUncheckedNegativeFixture

#MakeNegativeFixtureProbeBinding: {
	in: close({
		id:          #KebabIdentifier
		description: #NonEmptyString
		authority:   #CodexObligationState
		invalid:     #CodexObligationState
	})
	let builtFixture = (#MakeUncheckedNegativeFixture & {
		"in": in
	}).out
	out: #NegativeFixtureProbeBinding & {
		fixture: builtFixture
		probe: {
			authority: builtFixture.authority
			invalid:   builtFixture.invalid
		}
	}
}

// Checked constructor: returns a fixture/probe binding whose probe carries the
// destructive authority & invalid proof for expected-failure export validation.
#MakeNegativeFixture: #MakeNegativeFixtureProbeBinding

#MakeNegativeFixtureCheck: #MakeNegativeFixtureProbeBinding

#Subsumption: close({
	id:             #KebabIdentifier
	description:    #NonEmptyString
	_subsumptionID: id

	authority: #ClosedObligationState
	target:    #ClosedObligationState

	assertion: #Assertion & {
		id:          "subsumes-\(_subsumptionID)"
		mode:        "subsumes"
		family:      "subsumption"
		description: "Target state must not widen authority"
		expected:    authority
		observed:    target
		proof: #NoWideningProof & {authority: authority, target: target}
		proofStatus: "proven"
		noWidening:  true
	}
})

#MakeSubsumption: {
	in: close({
		id:          #KebabIdentifier
		description: #NonEmptyString
		authority:   #CodexObligationState
		target:      #CodexObligationState
	})
	let closedAuthority = (#MakeClosedObligationState & {"in": in.authority}).out
	let closedTarget = (#MakeClosedObligationState & {"in": in.target}).out
	out: #Subsumption & {
		id:          in.id
		description: in.description
		authority:   closedAuthority
		target:      closedTarget
		assertion: {
			id:          "subsumes-\(in.id)"
			mode:        "subsumes"
			family:      "subsumption"
			description: "Target state must not widen authority"
			expected:    closedAuthority
			observed:    closedTarget
			proof: #NoWideningProof & {authority: closedAuthority, target: closedTarget}
			proofStatus: "proven"
			noWidening:  true
		}
	}
}

#AuthorityDerivedTarget: close({
	authority: #CodexObligationState
	let closedAuthority = (#MakeClosedObligationState & {"in": authority}).out

	target: #ClosedObligationState & {
		id:        closedAuthority.id
		artifacts: closedAuthority.artifacts
		actions:   closedAuthority.actions
		checks:    closedAuthority.checks
		evidence:  closedAuthority.evidence
	}
})
