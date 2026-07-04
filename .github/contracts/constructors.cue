package impl

import (
	"list"
	"strings"
)

// Blueprint layer: bounded vocabulary, identifiers, closed shapes, and reference maps.
#NonEmptyString: string & strings.MinRunes(1)
#NonEmptyStringList: [...#NonEmptyString] & [_, ...]
#KebabIdentifier: #NonEmptyString & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#KebabMapKeyGuard: {
	[ID= !~"^[a-z0-9]+(-[a-z0-9]+)*$"]: {
		_invalidMapKey: ID & #KebabIdentifier
	}
}

#CodexActionKind:
	"inspect" |
	"edit" |
	"create" |
	"generate" |
	"validate" |
	"collectEvidence" |
	"report"

#ArtifactRole:
	"authority" |
	"input" |
	"mutationTarget" |
	"generatedOutput" |
	"evidence" |
	"forbidden"

#AssertionMode:
	"unifies" |
	"bottoms" |
	"subsumes" |
	"preserves" |
	"requires" |
	"forbids"

#FixturePolarity:
	"positive" |
	"negative"

#VisibilityTier:
	"public" |
	"internal" |
	"restricted"

#EvalFamily:
	"assertion" |
	"negativeFixture" |
	"subsumption" |
	"generatedMatrix"

#RefSet: close(#KebabMapKeyGuard & {
	[string]: true
})

// Input/matrix layer: declarative obligation state and witness records.
#Artifact: close({
	[F= !~"^(id|path|role|visibility)$"]: {
		_invalidField: F & =~"^(id|path|role|visibility)$"
	}

	id:         #KebabIdentifier
	path:       #NonEmptyString
	role:       #ArtifactRole
	visibility: #VisibilityTier | *"internal"
})

#Action: close({
	[F= !~"^(id|kind|description|reads|writes|creates|requiresChecks|requiresEvidence)$"]: {
		_invalidField: F & =~"^(id|kind|description|reads|writes|creates|requiresChecks|requiresEvidence)$"
	}

	id:          #KebabIdentifier
	kind:        #CodexActionKind
	description: #NonEmptyString

	reads:   #RefSet
	writes:  #RefSet
	creates: #RefSet

	requiresChecks:   #RefSet
	requiresEvidence: #RefSet
})

#Check: close({
	[F= !~"^(id|description|required)$"]: {
		_invalidField: F & =~"^(id|description|required)$"
	}

	id:          #KebabIdentifier
	description: #NonEmptyString
	required:    bool | *true
})

#Evidence: close({
	[F= !~"^(id|description|required)$"]: {
		_invalidField: F & =~"^(id|description|required)$"
	}

	id:          #KebabIdentifier
	description: #NonEmptyString
	required:    bool | *true
})

#CodexObligationState: close({
	id: #KebabIdentifier

	artifacts: close(#KebabMapKeyGuard & {
		[ID=#KebabIdentifier]: #Artifact & {
			id: ID
		}
	})

	actions: close(#KebabMapKeyGuard & {
		[ID=#KebabIdentifier]: #Action & {
			id: ID
		}
	})

	checks: close(#KebabMapKeyGuard & {
		[ID=#KebabIdentifier]: #Check & {
			id: ID
		}
	})

	evidence: close(#KebabMapKeyGuard & {
		[ID=#KebabIdentifier]: #Evidence & {
			id: ID
		}
	})
})

#ObligationState: #CodexObligationState

#ClosedObligationState: close({
	id: #KebabIdentifier

	artifacts: close(#KebabMapKeyGuard & {
		[ID=#KebabIdentifier]: #Artifact & {
			id: ID
		}
	})
	actions: close(#KebabMapKeyGuard & {
		[ID=#KebabIdentifier]: #Action & {
			id: ID
		}
	})
	checks: close(#KebabMapKeyGuard & {
		[ID=#KebabIdentifier]: #Check & {
			id: ID
		}
	})
	evidence: close(#KebabMapKeyGuard & {
		[ID=#KebabIdentifier]: #Evidence & {
			id: ID
		}
	})
})

#MakeClosedObligationState: {
	in: #CodexObligationState
	out: close({
		id: in.id

		artifacts: close({
			for artifactID, artifact in in.artifacts {
				"\(artifactID)": artifact & {
					id: artifactID
				}
			}
		})

		actions: close({
			for actionID, action in in.actions {
				"\(actionID)": action & {
					id: actionID
				}
			}
		})

		checks: close({
			for checkID, check in in.checks {
				"\(checkID)": check & {
					id: checkID
				}
			}
		})

		evidence: close({
			for evidenceID, item in in.evidence {
				"\(evidenceID)": item & {
					id: evidenceID
				}
			}
		})
	})
}

#StateKeySet: close({
	state: #ClosedObligationState

	artifacts: list.SortStrings([for key, _ in state.artifacts {key}])
	actions: list.SortStrings([for key, _ in state.actions {key}])
	checks: list.SortStrings([for key, _ in state.checks {key}])
	evidence: list.SortStrings([for key, _ in state.evidence {key}])
})

#ActionRefKeySet: close({
	action: #Action

	reads: list.SortStrings([for key, _ in action.reads {key}])
	writes: list.SortStrings([for key, _ in action.writes {key}])
	creates: list.SortStrings([for key, _ in action.creates {key}])
	requiresChecks: list.SortStrings([for key, _ in action.requiresChecks {key}])
	requiresEvidence: list.SortStrings([for key, _ in action.requiresEvidence {key}])
})

#NoWideningProof: close({
	authority: #ClosedObligationState
	target:    #ClosedObligationState

	authorityKeys: (#StateKeySet & {state: authority})
	targetKeys: (#StateKeySet & {state: target})

	keyEquality: {
		artifacts: authorityKeys.artifacts & targetKeys.artifacts
		actions:   authorityKeys.actions & targetKeys.actions
		checks:    authorityKeys.checks & targetKeys.checks
		evidence:  authorityKeys.evidence & targetKeys.evidence
	}

	actionRefEquality: {
		for actionID, _ in authority.actions {
			"\(actionID)": {
				authorityRefs: (#ActionRefKeySet & {action: authority.actions[actionID]})
				targetRefs: (#ActionRefKeySet & {action: target.actions[actionID]})

				reads:            authorityRefs.reads & targetRefs.reads
				writes:           authorityRefs.writes & targetRefs.writes
				creates:          authorityRefs.creates & targetRefs.creates
				requiresChecks:   authorityRefs.requiresChecks & targetRefs.requiresChecks
				requiresEvidence: authorityRefs.requiresEvidence & targetRefs.requiresEvidence
			}
		}
	}

	compatibility: authority & target
})

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
	}
})

#MakePositiveFixture: {
	in: close({
		id:          #KebabIdentifier
		description: #NonEmptyString
		authority:   #CodexObligationState
		candidate:   #CodexObligationState
	})
	_inputAuthority: in.authority
	_inputCandidate: in.candidate
	_authority: (#MakeClosedObligationState & {in: _inputAuthority}).out
	_candidate: (#MakeClosedObligationState & {in: _inputCandidate}).out
	out: #PositiveFixture & {
		id:          in.id
		description: in.description
		polarity:    "positive"
		authority:   _authority
		candidate:   _candidate
		proof:       _authority & _candidate
		assertion: {
			id:          "positive-\(in.id)"
			mode:        "unifies"
			family:      "assertion"
			description: "Candidate state must unify with authority"
			expected:    _authority
			observed:    _candidate
			proof:       _authority & _candidate
		}
	}
}

#NegativeFixture: close({
	id:          #KebabIdentifier
	description: #NonEmptyString
	polarity:    "negative"
	_fixtureID:  id

	authority: #ClosedObligationState
	invalid:   #ClosedObligationState
	proof:     authority & invalid

	assertion: #Assertion & {
		id:              "negative-\(_fixtureID)"
		mode:            "bottoms"
		family:          "negativeFixture"
		description:     "Invalid state must bottom against authority"
		expected:        authority
		invalid:         invalid
		proof:           proof
		expectedFailure: true
	}
})

#MakeNegativeFixture: {
	in: close({
		id:          #KebabIdentifier
		description: #NonEmptyString
		authority:   #CodexObligationState
		invalid:     #CodexObligationState
	})
	_inputAuthority: in.authority
	_inputInvalid:   in.invalid
	_authority: (#MakeClosedObligationState & {in: _inputAuthority}).out
	_invalid: (#MakeClosedObligationState & {in: _inputInvalid}).out
	out: #NegativeFixture & {
		id:          in.id
		description: in.description
		polarity:    "negative"
		authority:   _authority
		invalid:     _invalid
		proof:       _authority & _invalid
		assertion: {
			id:              "negative-\(in.id)"
			mode:            "bottoms"
			family:          "negativeFixture"
			description:     "Invalid state must bottom against authority"
			expected:        _authority
			invalid:         _invalid
			proof:           _authority & _invalid
			expectedFailure: true
		}
	}
}

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
		noWidening: true
	}
})

#MakeSubsumption: {
	in: close({
		id:          #KebabIdentifier
		description: #NonEmptyString
		authority:   #CodexObligationState
		target:      #CodexObligationState
	})
	_inputAuthority: in.authority
	_inputTarget:    in.target
	_authority: (#MakeClosedObligationState & {in: _inputAuthority}).out
	_target: (#MakeClosedObligationState & {in: _inputTarget}).out
	out: #Subsumption & {
		id:          in.id
		description: in.description
		authority:   _authority
		target:      _target
		assertion: {
			id:          "subsumes-\(in.id)"
			mode:        "subsumes"
			family:      "subsumption"
			description: "Target state must not widen authority"
			expected:    _authority
			observed:    _target
			proof: #NoWideningProof & {authority: _authority, target: _target}
			noWidening: true
		}
	}
}

#AuthorityDerivedTarget: close({
	authority:       #CodexObligationState
	_inputAuthority: authority
	_authority: (#MakeClosedObligationState & {in: _inputAuthority}).out

	target: #ClosedObligationState & {
		id:        _authority.id
		artifacts: _authority.artifacts
		actions:   _authority.actions
		checks:    _authority.checks
		evidence:  _authority.evidence
	}
})

// Generation layer: derive assertion matrices from compact obligation state.
#GeneratedAssertionMatrix: close({
	state: #ClosedObligationState

	assertions: {
		for actionID, action in state.actions {
			for artifactID, _ in action.reads {
				"action-\(actionID)-reads-artifact-\(artifactID)": #Assertion & {
					id:          "action-\(actionID)-reads-artifact-\(artifactID)"
					mode:        "requires"
					family:      "generatedMatrix"
					description: "Action read must reference an existing artifact"
					expected:    state.artifacts[artifactID]
					observed:    state.artifacts[artifactID]
					proof:       state.artifacts[artifactID]
				}
			}
		}

		for actionID, action in state.actions {
			for artifactID, _ in action.writes {
				"action-\(actionID)-writes-artifact-\(artifactID)": #Assertion & {
					id:          "action-\(actionID)-writes-artifact-\(artifactID)"
					mode:        "requires"
					family:      "generatedMatrix"
					description: "Action write must reference an existing artifact"
					expected:    state.artifacts[artifactID]
					observed:    state.artifacts[artifactID]
					proof:       state.artifacts[artifactID]
				}
			}
		}

		for actionID, action in state.actions {
			for artifactID, _ in action.creates {
				"action-\(actionID)-creates-artifact-\(artifactID)": #Assertion & {
					id:          "action-\(actionID)-creates-artifact-\(artifactID)"
					mode:        "requires"
					family:      "generatedMatrix"
					description: "Action create must reference an existing generated-output artifact"
					expected: state.artifacts[artifactID] & {
						role: "generatedOutput"
					}
					observed: state.artifacts[artifactID]
					proof: state.artifacts[artifactID] & {
						role: "generatedOutput"
					}
				}
			}
		}

		for actionID, action in state.actions {
			for checkID, _ in action.requiresChecks {
				"action-\(actionID)-requires-check-\(checkID)": #Assertion & {
					id:          "action-\(actionID)-requires-check-\(checkID)"
					mode:        "requires"
					family:      "generatedMatrix"
					description: "Required action must reference an existing check"
					expected:    state.checks[checkID]
					observed:    state.checks[checkID]
					proof:       state.checks[checkID]
				}
			}
		}

		for actionID, action in state.actions {
			for evidenceID, _ in action.requiresEvidence {
				"action-\(actionID)-requires-evidence-\(evidenceID)": #Assertion & {
					id:          "action-\(actionID)-requires-evidence-\(evidenceID)"
					mode:        "requires"
					family:      "generatedMatrix"
					description: "Required action must reference existing evidence"
					expected:    state.evidence[evidenceID]
					observed:    state.evidence[evidenceID]
					proof:       state.evidence[evidenceID]
				}
			}
		}

		for actionID, action in state.actions {
			for artifactID, _ in action.writes {
				if state.artifacts[artifactID].role == "forbidden" {
					"action-\(actionID)-must-not-write-\(artifactID)": #Assertion & {
						id:          "action-\(actionID)-must-not-write-\(artifactID)"
						mode:        "forbids"
						family:      "negativeFixture"
						description: "Action must not write forbidden artifact"
						expected:    state.artifacts[artifactID]
						invalid: {
							id:   artifactID
							path: state.artifacts[artifactID].path
							role: "mutationTarget"
						}
						expectedFailure: true
					}
				}
			}
		}
	}
})

#MakeGeneratedAssertionMatrix: {
	in: close({
		state: #CodexObligationState
	})
	_inputState: in.state
	_state: (#MakeClosedObligationState & {in: _inputState}).out
	out: #GeneratedAssertionMatrix & {
		state: _state
	}
}

// Projection layer: TDD/BDD fixtures are views over assertions and obligation state.
#TDDFixture: close({
	id:    #KebabIdentifier
	phase: "red" | "green" | "refactor"

	assertion: #Assertion
})

#BDDFixture: close({
	id:      #KebabIdentifier
	feature: #KebabIdentifier

	given: #CodexObligationState
	when:  #Action
	then:  #Assertion
})

// Exit-gate witnesses: validation and completion reports project kernel results.
#ValidationCommandKind:
	"cue-vet" |
	"cue-eval" |
	"cue-export" |
	"cue-export-expected-failure" |
	"matrix-assertion"

#ValidationCommand:
	close({
		kind: "cue-vet"
		argv: #NonEmptyStringList
	}) |
	close({
		kind: "cue-eval"
		argv: #NonEmptyStringList
	}) |
	close({
		kind: "cue-export"
		argv: #NonEmptyStringList
	}) |
	close({
		kind:                "cue-export-expected-failure"
		argv:                #NonEmptyStringList
		expectedFailure:     true
		expectedDiagnostic?: #NonEmptyString
	}) |
	close({
		kind:      "matrix-assertion"
		argv:      #NonEmptyStringList
		assertion: #KebabIdentifier
	})

#ValidationPlan: close({
	kind: "validation-plan"
	commands: [...#ValidationCommand] & [_, ...]
	assertions: close(#KebabMapKeyGuard & {
		[string]: #Assertion
	})
})

#MakeValidationPlan: {
	in: close({
		commands: [...#ValidationCommand] & [_, ...]
		assertions: close(#KebabMapKeyGuard & {
			[string]: #Assertion
		})
	})
	out: #ValidationPlan & {
		kind:       "validation-plan"
		commands:   in.commands
		assertions: in.assertions
	}
}

#CompletionReportContract: close({
	kind:             "completion-report-contract"
	requiredSections: #NonEmptyStringList
	expected: close({
		state: #KebabIdentifier
		assertions: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		fixtures: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		subsumptions: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		commands: [...#ValidationCommand] & [_, ...]
		evidence: close(#KebabMapKeyGuard & {
			[string]: bool
		})
	})
})

#MakeCompletionReport: {
	in: close({
		state: #KebabIdentifier
		assertions: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		fixtures: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		subsumptions: close(#KebabMapKeyGuard & {
			[string]: bool
		})
		commands: [...#ValidationCommand] & [_, ...]
		evidence: close(#KebabMapKeyGuard & {
			[string]: bool
		})
	})
	out: #CompletionReportContract & {
		kind: "completion-report-contract"
		requiredSections: [
			"summary",
			"obligation state",
			"assertions",
			"negative fixtures",
			"subsumptions",
			"generated matrix",
			"validation",
			"evidence",
			"final result",
		]
		expected: in
	}
}
