package impl

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
					proofStatus: "proven"
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
					proofStatus: "proven"
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
					proofStatus: "proven"
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
					proofStatus: "proven"
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
					proofStatus: "proven"
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
						proofStatus:     "requiresDestructiveProbe"
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
	let closedState = (#MakeClosedObligationState & {"in": in.state}).out
	out: #GeneratedAssertionMatrix & {
		state: closedState
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
