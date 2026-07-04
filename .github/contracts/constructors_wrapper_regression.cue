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

_uncheckedNegativeFixtureWitnessWithActions: (#MakeUncheckedNegativeFixture & {
	in: {
		id:          "unchecked-negative-actions"
		description: "Unchecked negative witness accepts action map entries"
		authority:   _validState
		invalid:     _validState
	}
}).out

_uncheckedNegativeFixtureAllowsNonConflict: (#MakeUncheckedNegativeFixture & {
	in: {
		id:          "unchecked-negative-non-conflict"
		description: "Unchecked negative witness can export without proving bottom"
		authority:   _validState
		invalid:     _validState
	}
}).out

_uncheckedNegativeFixtureExportable: (#MakeUncheckedNegativeFixture & {
	in: {
		id:          "negative-conflict"
		description: "Unchecked negative wrapper exports witness metadata"
		authority:   _validState
		invalid:     _invalidState
	}
}).out

_negativeFixtureCheck: (#MakeNegativeFixtureCheck & {
	in: {
		id:          "negative-conflict"
		description: "Negative fixture derives paired probe spec"
		authority:   _validState
		invalid:     _invalidState
	}
}).out

_negativeFixtureConflictProbe: _negativeFixtureCheck.probe & {
	authority: _negativeFixtureCheck.probe.authority
	invalid:   _negativeFixtureCheck.probe.invalid
	proof?:    authority & invalid
}

_negativeFixtureValidationCommand: #CueExportExpectedFailure & {
	expr: "_negativeFixtureConflictProbe.proof"
	tags: ["negativeproof"]
}

_negativeFixtureNonConflictCheck: (#MakeNegativeFixtureCheck & {
	in: {
		id:          "negative-non-conflict-control"
		description: "Identical states must not bottom"
		authority:   _validState
		invalid:     _validState
	}
}).out

_negativeFixtureNonConflictProbe: #NegativeFixtureConflictProbe & _negativeFixtureNonConflictCheck.probe

_negativeFixtureNonConflictCommand: #CueExportExpectedSuccess & {
	expr: "_negativeFixtureNonConflictProbe"
}

_defaultPackageExportCommand: #CueExportPackageExpectedSuccess & {}

_validationCases: [...#ValidationCase] & [
	{
		id:          "default-package-export"
		description: "Default contract package export must remain clean"
		command:     _defaultPackageExportCommand
	},
	{
		id:          "negative-fixture-conflict"
		description: "Negative conflict probe must bottom"
		command:     _negativeFixtureValidationCommand
	},
	{
		id:          "negative-fixture-non-conflict-control"
		description: "Identical-state conflict probe must export"
		command:     _negativeFixtureNonConflictCommand
	},
]

validationManifest: {
	validationCases: _validationCases
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
