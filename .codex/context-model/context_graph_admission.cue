package contextmodel

// Admission changes effective semantic authority without mutating the collected
// evidence object. The evidence's own authority remains bounded by the collection
// policy; elevated authority exists only in a provenance-bound admitted state.
#ContextEvidenceAuthorityState: close({
	schema:             "kernel.context-evidence-authority-state.v0"
	evidenceID:         #GraphID
	snapshotID:         #Digest
	evidence:           #ContextEvidence & {payloadDigest: #ContentDigest}
	effectiveAuthority: #ClaimAuthority
})

#ContextCollectedEvidenceEnvelope: close({
	schema: "kernel.context-evidence-collection.v0"
	State=state: #ContextEvidenceAuthorityState & {
		effectiveAuthority: State.evidence.authority
	}
	admission: null
})

#ContextEvidenceAdmissionRecord: close({
	schema:           "kernel.context-evidence-admission-record.v0"
	admissionID:      #GraphID
	decisionDigest:   #Digest
	evidenceID:       #GraphID
	evidenceDigest:   #ContentDigest
	sourceSnapshotID: #Digest
	policyDigest:     #Digest
	actor:            #ContextEntityRef
	from:             #ClaimAuthority
	to:               #ClaimAuthority
})

#ContextAuthorityTransitionExpectedResult: "accept" | "reject"

// Authority may be preserved or increased, but never demoted. A preserved
// transition is the deterministic replay/idempotence case.
#ContextAuthorityTransitionExpectations: close({
	none: close({
		none:       "accept"
		candidate:  "accept"
		controller: "accept"
		root:       "accept"
	})
	candidate: close({
		none:       "reject"
		candidate:  "accept"
		controller: "accept"
		root:       "accept"
	})
	controller: close({
		none:       "reject"
		candidate:  "reject"
		controller: "accept"
		root:       "accept"
	})
	root: close({
		none:       "reject"
		candidate:  "reject"
		controller: "reject"
		root:       "accept"
	})
})

#ContextNoAdmissionTransitionExpectations: close({
	none: close({
		none:       "accept"
		candidate:  "reject"
		controller: "reject"
		root:       "reject"
	})
	candidate: close({
		none:       "reject"
		candidate:  "accept"
		controller: "reject"
		root:       "reject"
	})
	controller: close({
		none:       "reject"
		candidate:  "reject"
		controller: "accept"
		root:       "reject"
	})
	root: close({
		none:       "reject"
		candidate:  "reject"
		controller: "reject"
		root:       "accept"
	})
})

#ContextEvidenceNoAdmissionTransition: close({
	schema:        "kernel.context-evidence-no-admission-transition.v0"
	Before=before: #ContextEvidenceAuthorityState
	after: #ContextEvidenceAuthorityState & {
		evidenceID:         Before.evidenceID
		snapshotID:         Before.snapshotID
		evidence:           Before.evidence
		effectiveAuthority: Before.effectiveAuthority
	}
	admission: null
})

#ContextEvidenceAdmissionTransition: close({
	schema:                    "kernel.context-evidence-admission-transition.v0"
	PolicyDigest=policyDigest: #Digest
	Before=before:             #ContextEvidenceAuthorityState
	After=after: #ContextEvidenceAuthorityState & {
		evidenceID: Before.evidenceID
		snapshotID: Before.snapshotID
		evidence:   Before.evidence
	}
	admission: #ContextEvidenceAdmissionRecord & {
		evidenceID:       Before.evidenceID
		evidenceDigest:   Before.evidence.payloadDigest
		sourceSnapshotID: Before.snapshotID
		policyDigest:     PolicyDigest
		from:             Before.effectiveAuthority
		to:               After.effectiveAuthority
	}
	_transitionAllowed: #ContextAuthorityTransitionExpectations[Before.effectiveAuthority][After.effectiveAuthority] & "accept"
})

#ContextEvidenceAuthorityProjection: close({
	schema:         "kernel.context-evidence-authority-projection.v0"
	projectionKind: #GraphID
	Source=source:  #ContextEvidenceAuthorityState
	projected: #ContextEvidenceAuthorityState & {
		evidenceID:         Source.evidenceID
		snapshotID:         Source.snapshotID
		evidence:           Source.evidence
		effectiveAuthority: Source.effectiveAuthority
	}
})

#ContextEvidenceAdmissionBundle: close({
	schema: "kernel.context-evidence-admission-bundle.v0"
	states: [StateID=#GraphID]: #ContextEvidenceAuthorityState & {evidenceID: StateID}
	admissions: [AdmissionID=#GraphID]: #ContextEvidenceAdmissionTransition & {
		admission: admissionID: AdmissionID
	}
	_admissionStateRefs: [for _, transition in admissions {
		[for stateID, _ in states if stateID == transition.before.evidenceID {stateID}] & [_, ...]
	}]
})

#ContextEvidenceAdmissionScenario:
	"no-admission" |
		"valid-admission" |
		"wrong-evidence-id" |
		"wrong-evidence-digest" |
		"wrong-snapshot" |
		"wrong-policy-digest" |
		"unknown-field"

#ContextEvidenceAdmissionCase: close({
	id:       #GraphID
	from:     #ClaimAuthority
	to:       #ClaimAuthority
	scenario: #ContextEvidenceAdmissionScenario
	expected: #ContextAuthorityTransitionExpectedResult
})

#ContextEvidenceAdmissionMatrix: close({
	schema: "kernel.context-evidence-admission-matrix.v0"
	cases: [ID=#GraphID]: #ContextEvidenceAdmissionCase & {id: ID}
})

#ContextEvidenceAdmissionScenarios: close({
	"no-admission":          true
	"valid-admission":       true
	"wrong-evidence-id":     true
	"wrong-evidence-digest": true
	"wrong-snapshot":        true
	"wrong-policy-digest":   true
	"unknown-field":         true
})

// Exhaustive executable projection of all 4 × 4 authority pairs under every
// valid and malformed admission scenario.
contextEvidenceAdmissionMatrix: #ContextEvidenceAdmissionMatrix & {
	cases: {
		for fromAuthority, transitionExpectations in #ContextAuthorityTransitionExpectations {
			for toAuthority, transitionExpected in transitionExpectations {
				for scenarioName, _ in #ContextEvidenceAdmissionScenarios {
					"admission.\(fromAuthority).\(toAuthority).\(scenarioName)": {
						id:       "admission.\(fromAuthority).\(toAuthority).\(scenarioName)"
						from:     fromAuthority
						to:       toAuthority
						scenario: scenarioName
						if scenarioName == "no-admission" {
							expected: #ContextNoAdmissionTransitionExpectations[fromAuthority][toAuthority]
						}
						if scenarioName == "valid-admission" {
							expected: transitionExpected
						}
						if scenarioName != "no-admission" && scenarioName != "valid-admission" {
							expected: "reject"
						}
					}
				}
			}
		}
	}
}
