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

_negativeFixtureCheckedWithActions: (#MakeNegativeFixture & {
	in: {
		id:          "negative-actions"
		description: "Negative wrapper returns checked probe binding"
		authority:   _validState
		invalid:     _validState
	}
}).out

_negativeFixtureCheckedSpecRequiresProbe: _negativeFixtureCheckedWithActions.fixture.assertion.proofStatus & "requiresDestructiveProbe"
_negativeFixtureCheckedProbeProof:        _negativeFixtureCheckedWithActions.probe.proof

_negativeFixtureSpecWithActions: (#MakeNegativeFixtureSpec & {
	in: {
		id:          "negative-spec-actions"
		description: "Negative spec wrapper returns unchecked metadata"
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

_negativeFixtureValidationCommand: #CueExportExpectedFailure & {
	expr: "_negativeFixtureProbeBinding.probe.proof"
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

_negativeFixtureNonConflictProbe: _negativeFixtureNonConflictBinding.probe

_negativeFixtureNonConflictCommand: #CueExportExpectedSuccess & {
	expr: "_negativeFixtureNonConflictProbe"
}

_negativeFixtureSpecAliasProbeAccessCommand: #CueExportExpectedFailure & {
	expr: "_negativeFixtureSpecWithActions.probe"
}

_negativeFixtureCheckedAliasProbeAccessCommand: #CueExportExpectedSuccess & {
	expr: "_negativeFixtureCheckedWithActions.probe"
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
		id:          "negative-fixture-spec-alias-spec-only"
		description: "#MakeNegativeFixtureSpec must not expose a checked probe field"
		command:     _negativeFixtureSpecAliasProbeAccessCommand
	},
	{
		id:          "negative-fixture-checked-alias-probe"
		description: "#MakeNegativeFixture must expose a checked probe field"
		command:     _negativeFixtureCheckedAliasProbeAccessCommand
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
