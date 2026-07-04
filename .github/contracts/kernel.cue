package impl

import (
	"list"
	"strings"
)

// Blueprint layer: bounded vocabulary, identifiers, closed shapes, and reference maps.
#NonEmptyString: string & strings.MinRunes(1)
#NonEmptyStringList: [...#NonEmptyString] & [_, ...]
#KebabIdentifier: #NonEmptyString & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#CueSelectorExpr: #NonEmptyString & =~"^[_#A-Za-z][_A-Za-z0-9]*(\\.[_A-Za-z][_A-Za-z0-9]*)*$"
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

#ProofStatus:
	"notApplicable" |
	"proven" |
	"requiresDestructiveProbe"

#RefSet: {
	[ID= !~"^[a-z0-9]+(-[a-z0-9]+)*$"]: {
		_invalidMapKey: ID & #KebabIdentifier
	}
	[string]: true
}

// Generic lattice aliases. Domain profiles may keep older names while projecting to
// the same obligation/effect graph kernel.
#ResourceRole: #ArtifactRole
#OperationKind: #CodexActionKind

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

#Resource: #Artifact

#Action: {
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
}

#Operation: #Action

#Check: close({
	[F= !~"^(id|description|required)$"]: {
		_invalidField: F & =~"^(id|description|required)$"
	}

	id:          #KebabIdentifier
	description: #NonEmptyString
	required:    bool | *true
})

#Gate: #Check

#Evidence: close({
	[F= !~"^(id|description|required)$"]: {
		_invalidField: F & =~"^(id|description|required)$"
	}

	id:          #KebabIdentifier
	description: #NonEmptyString
	required:    bool | *true
})

#Witness: #Evidence

#ArtifactMap: {
	[ID= !~"^[a-z0-9]+(-[a-z0-9]+)*$"]: {
		_invalidMapKey: ID & #KebabIdentifier
	}
	[string]: #Artifact
	[ID=string]: {
		id: ID
	}
}

#ResourceMap: #ArtifactMap

#ActionMap: {
	[ID= !~"^[a-z0-9]+(-[a-z0-9]+)*$"]: {
		_invalidMapKey: ID & #KebabIdentifier
	}
	[string]: #Action
	[ID=string]: {
		id: ID
	}
}

#OperationMap: #ActionMap

#CheckMap: {
	[ID= !~"^[a-z0-9]+(-[a-z0-9]+)*$"]: {
		_invalidMapKey: ID & #KebabIdentifier
	}
	[string]: #Check
	[ID=string]: {
		id: ID
	}
}

#GateMap: #CheckMap

#EvidenceMap: {
	[ID= !~"^[a-z0-9]+(-[a-z0-9]+)*$"]: {
		_invalidMapKey: ID & #KebabIdentifier
	}
	[string]: #Evidence
	[ID=string]: {
		id: ID
	}
}

#WitnessMap: #EvidenceMap

#CodexObligationState: {
	[F= !~"^(id|artifacts|actions|checks|evidence)$"]: {
		_invalidField: F & =~"^(id|artifacts|actions|checks|evidence)$"
	}

	id: #KebabIdentifier

	artifacts: #ArtifactMap
	actions:   #ActionMap
	checks:    #CheckMap
	evidence:  #EvidenceMap
}

#ObligationState: #CodexObligationState
#LatticeObligationState: #ObligationState

#ClosedObligationState: {
	[F= !~"^(id|artifacts|actions|checks|evidence)$"]: {
		_invalidField: F & =~"^(id|artifacts|actions|checks|evidence)$"
	}

	id: #KebabIdentifier

	artifacts: #ArtifactMap
	actions:   #ActionMap
	checks:    #CheckMap
	evidence:  #EvidenceMap
}

#ClosedLatticeObligationState: #ClosedObligationState

#MakeClosedObligationState: {
	in: #CodexObligationState
	out: #ClosedObligationState & {
		id: in.id

		artifacts: {
			for artifactID, artifact in in.artifacts {
				"\(artifactID)": artifact & {
					id: artifactID
				}
			}
		}

		actions: {
			for actionID, action in in.actions {
				"\(actionID)": action & {
					id: actionID
				}
			}
		}

		checks: {
			for checkID, check in in.checks {
				"\(checkID)": check & {
					id: checkID
				}
			}
		}

		evidence: {
			for evidenceID, item in in.evidence {
				"\(evidenceID)": item & {
					id: evidenceID
				}
			}
		}
	}
}

#MakeClosedLatticeObligationState: #MakeClosedObligationState

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

#OperationRefKeySet: #ActionRefKeySet

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
