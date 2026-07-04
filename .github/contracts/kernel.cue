package impl

import (
	"list"

	lat "github.com/fatb4f/lattice/domain"
)

// Shared primitive constraints are owned by the lattice domain kernel.
#NonEmptyString:     lat.#NonEmptyString
#NonEmptyStringList: lat.#NonEmptyStringList
#KebabIdentifier:   lat.#KebabIdentifier
#CueSelectorExpr:   lat.#CueSelectorExpr
#KebabMapKeyGuard:  lat.#KebabMapKeyGuard
#RefSet:            lat.#RefSet
#VisibilityTier:    lat.#VisibilityTier

// Codex profile vocabulary.
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

#EvalFamily:
	"assertion" |
	"negativeFixture" |
	"subsumption" |
	"generatedMatrix"

#ProofStatus:
	"notApplicable" |
	"proven" |
	"requiresDestructiveProbe"

// Generic lattice aliases retained for profile consumers.
#ResourceRole:  #ArtifactRole
#OperationKind: #CodexActionKind

// Codex profile records refine the generic lattice domain records.
#Artifact: lat.#Resource & close({
	[F= !~"^(id|path|role|visibility)$"]: {
		_invalidField: F & =~"^(id|path|role|visibility)$"
	}

	id:         #KebabIdentifier
	path:       #NonEmptyString
	role:       #ArtifactRole
	visibility: #VisibilityTier | *"internal"
})

#Resource: #Artifact

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

#Operation: #Action

#Check: lat.#Gate & close({
	[F= !~"^(id|description|required)$"]: {
		_invalidField: F & =~"^(id|description|required)$"
	}

	id:          #KebabIdentifier
	description: #NonEmptyString
	required:    bool | *true
})

#Gate: #Check

#Evidence: lat.#Witness & close({
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

// Domain-neutral state surface from the extracted lattice module.
#LatticeObligationState:       lat.#ObligationState
#ClosedLatticeObligationState: lat.#ClosedObligationState

#ToLatticeOperation: close({
	in: #Action
	out: lat.#Operation & {
		id:          in.id
		kind:        in.kind
		description: in.description

		reads:   in.reads
		writes:  in.writes
		creates: in.creates

		requiresGates:     in.requiresChecks
		requiresWitnesses: in.requiresEvidence
	}
})

#ToLatticeObligationState: close({
	in: #CodexObligationState
	out: lat.#ObligationState & {
		id: in.id

		resources: in.artifacts
		operations: {
			for actionID, action in in.actions {
				"\(actionID)": (#ToLatticeOperation & {in: action}).out
			}
		}
		gates:     in.checks
		witnesses: in.evidence
	}
})

#FromLatticeOperation: close({
	in: lat.#Operation
	out: #Action & {
		id:          in.id
		kind:        in.kind & #CodexActionKind
		description: in.description

		reads:   in.reads
		writes:  in.writes
		creates: in.creates

		requiresChecks:   in.requiresGates
		requiresEvidence: in.requiresWitnesses
	}
})

#FromLatticeObligationState: close({
	in: lat.#ObligationState
	out: #CodexObligationState & {
		id: in.id

		artifacts: in.resources
		actions: {
			for operationID, operation in in.operations {
				"\(operationID)": (#FromLatticeOperation & {in: operation}).out
			}
		}
		checks:   in.gates
		evidence: in.witnesses
	}
})

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

#MakeClosedLatticeObligationState: lat.#MakeClosedObligationState

#StateKeySet: close({
	state: #ClosedObligationState

	artifacts: list.SortStrings([for key, _ in state.artifacts {key}])
	actions:   list.SortStrings([for key, _ in state.actions {key}])
	checks:    list.SortStrings([for key, _ in state.checks {key}])
	evidence:  list.SortStrings([for key, _ in state.evidence {key}])
})

#ActionRefKeySet: close({
	action: #Action

	reads:            list.SortStrings([for key, _ in action.reads {key}])
	writes:           list.SortStrings([for key, _ in action.writes {key}])
	creates:          list.SortStrings([for key, _ in action.creates {key}])
	requiresChecks:   list.SortStrings([for key, _ in action.requiresChecks {key}])
	requiresEvidence: list.SortStrings([for key, _ in action.requiresEvidence {key}])
})

#OperationRefKeySet: #ActionRefKeySet

#NoWideningProof: close({
	authority: #ClosedObligationState
	target:    #ClosedObligationState

	authorityKeys: (#StateKeySet & {state: authority})
	targetKeys:    (#StateKeySet & {state: target})

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
				targetRefs:    (#ActionRefKeySet & {action: target.actions[actionID]})

				reads:            authorityRefs.reads & targetRefs.reads
				writes:           authorityRefs.writes & targetRefs.writes
				creates:          authorityRefs.creates & targetRefs.creates
				requiresChecks:   authorityRefs.requiresChecks & targetRefs.requiresChecks
				requiresEvidence: authorityRefs.requiresEvidence & targetRefs.requiresEvidence
			}
		}
	}

	authorityLattice: (#ToLatticeObligationState & {in: authority}).out
	targetLattice:    (#ToLatticeObligationState & {in: target}).out
	latticeProof: lat.#NoWideningProof & {
		authority: authorityLattice
		target:    targetLattice
	}

	compatibility: authority & target
})
