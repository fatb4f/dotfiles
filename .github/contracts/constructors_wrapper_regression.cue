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

_negativeFixtureSpecWithActions: (#MakeNegativeFixture & {
	in: {
		id:          "negative-actions"
		description: "Negative wrapper returns unchecked spec metadata"
		authority:   _validState
		invalid:     _validState
	}
}).out

_negativeFixtureSpecRequiresProbe: _negativeFixtureSpecWithActions.assertion.proofStatus & "requiresDestructiveProbe"

_uncheckedNegativeFixtureAllowsNonConflict: (#MakeUncheckedNegativeFixture & {
	in: {
		id:          "unchecked-negative-non-conflict"
		description: "Unchecked negative spec can export without proving bottom"
		authority:   _validState
		invalid:     _validState
	}
}).out

_uncheckedNegativeFixtureExportable: (#MakeUncheckedNegativeFixture & {
	in: {
		id:          "negative-conflict"
		description: "Unchecked negative wrapper exports spec metadata"
		authority:   _validState
		invalid:     _invalidState
	}
}).out

_negativeFixtureProbeBinding: (#MakeNegativeFixtureProbeBinding & {
	in: {
		id:          "negative-conflict"
		description: "Negative fixture derives paired destructive probe input"
		authority:   _validState
		invalid:     _invalidState
	}
}).out

_negativeFixtureConflictProbe: _negativeFixtureProbeBinding.probe

_negativeFixtureValidationCommand: #CueExportExpectedFailure & {
	expr: "_negativeFixtureConflictProbe.proof"
	tags: ["negativeproof"]
}

_negativeFixtureNonConflictBinding: (#MakeNegativeFixtureProbeBinding & {
	in: {
		id:          "negative-non-conflict-control"
		description: "Identical states must not bottom"
		authority:   _validState
		invalid:     _validState
	}
}).out

_negativeFixtureNonConflictProbe: #NegativeFixtureConflictProbe & _negativeFixtureNonConflictBinding.probe

_negativeFixtureNonConflictCommand: #CueExportExpectedSuccess & {
	expr: "_negativeFixtureNonConflictProbe"
}

_negativeFixtureAliasProbeAccessCommand: #CueExportExpectedFailure & {
	expr: "_negativeFixtureSpecWithActions.probe"
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
	{
		id:          "negative-fixture-alias-spec-only"
		description: "#MakeNegativeFixture must not expose a checked probe field"
		command:     _negativeFixtureAliasProbeAccessCommand
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
