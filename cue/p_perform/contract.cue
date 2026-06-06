package p_perform

#ChangedPath: {
	path:       string
	taskID:     string
	declaredIn: string
}

#ValidationResult: {
	id:       string
	command:  string
	passed:   bool
	evidence: string
}

#PromotionCandidate: {
	id: string

	taskGraphContract:         _
	taskGraphContractAccepted: true
	loadedContext:             _
	loadedContextAccepted:     true

	changedPaths: [...#ChangedPath]
	validations: [...#ValidationResult]

	checks: {
		changedPathsMatchTaskGraph: true
		noUndeclaredMutation:       true
		validationsPassed:          true
		priorAcceptedStatesHeld:    true
		readyForMutationWasFalse:   true
		readyForExport:             true
		ambiguityCount:             0

		for validation in validations {
			validationsPassed: validation.passed == true
		}
	}

	agent: {
		role:       "codex-worktree"
		ownsPolicy: false
	}

	runner: {
		role:       "ambient-worktree" | "apply-patch" | "validation-command"
		ownsPolicy: false
	}

	ambiguity: [...string]
}

#PromotePhase: {
	"@context": "https://fatb4f.dev/ns/ralph/promote/v0"
	"@id":      "ralph:P"
	"@type":    "ralph:PhaseNode"

	id:   "P"
	name: "promote"

	input: {
		taskGraphContract:     _
		loadedContext:         _
		loadedContextAccepted: true
	}

	output: #PromotionCandidate

	accepted: output.checks.changedPathsMatchTaskGraph == true && output.checks.noUndeclaredMutation == true && output.checks.validationsPassed == true && output.checks.priorAcceptedStatesHeld == true && output.checks.readyForExport == true && len(output.ambiguity) == 0

	control: {
		invariants: [
			"P validates observed mutation evidence",
			"P changed paths must match the accepted graph",
			"P does not broaden mutation scope",
			"P preserves prior accepted states",
			"P emits an export candidate only",
		]
	}
}
