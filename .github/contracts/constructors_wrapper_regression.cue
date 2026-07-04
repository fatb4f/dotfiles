package impl

_validState: {
	id: "valid-state"

	artifacts: {
		"authority-file": {
			path: "contracts/constructors.cue"
			role: "authority"
		}
		"generated-file": {
			path: "generated/assertions.json"
			role: "generatedOutput"
		}
	}

	actions: {
		"inspect-action": {
			kind:        "inspect"
			description: "Inspect authority contract and generate assertions"
			reads: {
				"authority-file": true
			}
			writes: {}
			creates: {
				"generated-file": true
			}
			requiresChecks: {
				"cue-vet": true
			}
			requiresEvidence: {
				"inspection-report": true
			}
		}
	}

	checks: {
		"cue-vet": {
			description: "Run cue vet for contract package"
		}
	}

	evidence: {
		"inspection-report": {
			description: "Recorded wrapper-constructor validation evidence"
		}
	}
}

_invalidState: {
	id: "valid-state"

	artifacts: {
		"authority-file": {
			path: "contracts/constructors.cue"
			role: "forbidden"
		}
		"generated-file": {
			path: "generated/assertions.json"
			role: "generatedOutput"
		}
	}

	actions: {
		"inspect-action": {
			kind:        "inspect"
			description: "Inspect authority contract and generate assertions"
			reads: {
				"authority-file": true
			}
			writes: {}
			creates: {
				"generated-file": true
			}
			requiresChecks: {
				"cue-vet": true
			}
			requiresEvidence: {
				"inspection-report": true
			}
		}
	}

	checks: {
		"cue-vet": {
			description: "Run cue vet for contract package"
		}
	}

	evidence: {
		"inspection-report": {
			description: "Recorded wrapper-constructor validation evidence"
		}
	}
}

_directCodexState: #CodexObligationState & _validState
_directClosedState: (#MakeClosedObligationState & {in: _validState}).out
_closedStateAccepted: #ClosedObligationState & _directClosedState

_positiveFixtureWithActions: (#MakePositiveFixture & {
	in: {
		id:          "positive-actions"
		description: "Positive wrapper accepts action map entries"
		authority:   _validState
		candidate:   _validState
	}
}).out

_negativeFixtureWithActions: (#MakeNegativeFixture & {
	in: {
		id:          "negative-actions"
		description: "Negative wrapper accepts action map entries before bottom proof"
		authority:   _validState
		invalid:     _validState
	}
}).out

_negativeFixtureExportable: (#MakeNegativeFixture & {
	in: {
		id:          "negative-conflict"
		description: "Negative wrapper exports witness metadata"
		authority:   _validState
		invalid:     _invalidState
	}
}).out

_negativeFixtureCheck: (#MakeNegativeFixtureCheck & {
	in: {
		id:          "negative-conflict"
		description: "Negative wrapper couples witness to expected-failure probe"
		authority:   _validState
		invalid:     _invalidState
		expr:        "(#NegativeFixtureConflictProbe & {authority: (#MakeClosedObligationState & {\"in\": _validState}).out, invalid: (#MakeClosedObligationState & {\"in\": _invalidState}).out})"
	}
}).out

_negativeFixtureNonConflictProbe: #NegativeFixtureConflictProbe & {
	authority: (#MakeClosedObligationState & {"in": _validState}).out
	invalid: (#MakeClosedObligationState & {"in": _validState}).out
}

_subsumptionWithActions: (#MakeSubsumption & {
	in: {
		id:          "subsumption-actions"
		description: "Subsumption wrapper accepts action map entries"
		authority:   _validState
		target:      _validState
	}
}).out

_generatedMatrixWithActions: (#MakeGeneratedAssertionMatrix & {
	in: {
		state: _validState
	}
}).out
