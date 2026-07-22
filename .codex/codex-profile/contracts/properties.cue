package codexprofile

#PropertyMutationClass:
	"duplicate-coordinate" |
		"replace-admitted-raw" |
		"elevate-authority" |
		"collapse-unavailable-to-null" |
		"timestamp-ordering" |
		"invalid-freshness" |
		"invalid-token-arithmetic" |
		"synthetic-lineage-over-native" |
		"merge-journal-lifecycle" |
		"non-collector-write" |
		"couple-policy-axes"

#PropertyExpectedResult: "accept" | "reject"

#ContractProperty: close({
	id:               #ID
	description:      #NonEmptyString
	targetDefinition: #NonEmptyString
	preconditions:    [...#NonEmptyString] & [_, ...]
	mutationClass:    #PropertyMutationClass
	preservedTerms:   [...#ID]
	changedTerms:     [...#ID] & [_, ...]
	expectedResult:   #PropertyExpectedResult
	rejectionCode:    #ID | null
})

#ContractPropertyCatalog: close({
	schema: "codex-profile-properties.v0"
	properties: [ID=#ID]: #ContractProperty & {id: ID}
})

assertionCatalog: #ContractPropertyCatalog & {
	properties: {
		"source.identity-deduplication": {
			description:      "Physical identity is the source identity and byte offset; derived indexes cannot replace it."
			targetDefinition: "#RawObservationEnvelope"
			preconditions:    ["Two observations address one source coordinate."]
			mutationClass:    "duplicate-coordinate"
			preservedTerms:   ["source.identity", "source.offset"]
			changedTerms:     ["observation.id"]
			expectedResult:   "reject"
			rejectionCode:    "duplicate.physical-identity"
		}
		"source.append-only-admission": {
			description:      "Raw admission appends complete records and never replaces an admitted fact."
			targetDefinition: "#RawObservationEnvelope"
			preconditions:    ["A raw observation has already been admitted."]
			mutationClass:    "replace-admitted-raw"
			preservedTerms:   ["source.identity", "source.offset"]
			changedTerms:     ["payload.digest"]
			expectedResult:   "reject"
			rejectionCode:    "raw.not-append-only"
		}
		"authority.provenance-bounded": {
			description:      "Observed facts retain their source authority and cannot self-promote to checkpoint or derived authority."
			targetDefinition: "#Provenance"
			preconditions:    ["The value originated at an observed source."]
			mutationClass:    "elevate-authority"
			preservedTerms:   ["source.coordinate"]
			changedTerms:     ["provenance.authority"]
			expectedResult:   "reject"
			rejectionCode:    "authority.elevation"
		}
		"facts.nullable-vs-unavailable": {
			description:      "Unavailable native facts carry a reason and are not collapsed into nullable backend fields."
			targetDefinition: "#AvailableUInt"
			preconditions:    ["A native fact was not observed."]
			mutationClass:    "collapse-unavailable-to-null"
			preservedTerms:   []
			changedTerms:     ["fact.availability"]
			expectedResult:   "reject"
			rejectionCode:    "fact.availability-lost"
		}
		"ordering.explicit-correlation-only": {
			description:      "Cross-source order requires an explicit admitted correlation edge; timestamps are diagnostic only."
			targetDefinition: "#CrossSourceOrderClaim"
			preconditions:    ["The coordinates belong to different sources."]
			mutationClass:    "timestamp-ordering"
			preservedTerms:   ["source.coordinates"]
			changedTerms:     ["correlation.edges"]
			expectedResult:   "reject"
			rejectionCode:    "ordering.missing-edge"
		}
		"checkpoint.freshness-categorical": {
			description:      "Checkpoint freshness is exactly exact, stale, invalid, or unknown; age cannot create a fifth validity state."
			targetDefinition: "#CheckpointFreshness"
			preconditions:    ["A checkpoint assessment is emitted."]
			mutationClass:    "invalid-freshness"
			preservedTerms:   ["checkpoint.id"]
			changedTerms:     ["checkpoint.freshness"]
			expectedResult:   "reject"
			rejectionCode:    "checkpoint.invalid-freshness"
		}
		"usage.token-accounting": {
			description:      "Token fields are nonnegative, cached input does not exceed reported input, and fresh input is their difference."
			targetDefinition: "#UsageObservation"
			preconditions:    ["A TokenCountEvent observation is normalized."]
			mutationClass:    "invalid-token-arithmetic"
			preservedTerms:   ["source.coordinate"]
			changedTerms:     ["usage.cached", "usage.fresh"]
			expectedResult:   "reject"
			rejectionCode:    "usage.invalid-accounting"
		}
		"lineage.native-migration": {
			description:      "Native context-window identity is retained; legacy numeric identity is represented only as window number."
			targetDefinition: "#ContextWindowObservation"
			preconditions:    ["Native lineage is present or a legacy record is migrated."]
			mutationClass:    "synthetic-lineage-over-native"
			preservedTerms:   ["thread.id", "window.number"]
			changedTerms:     ["window.identity"]
			expectedResult:   "reject"
			rejectionCode:    "lineage.native-identity-lost"
		}
		"journal.lifecycle-separated": {
			description:      "Hook start and completion remain separate immutable records and unresolved starts remain observable."
			targetDefinition: "#HookStarted|#HookCompleted"
			preconditions:    ["A hook invocation starts."]
			mutationClass:    "merge-journal-lifecycle"
			preservedTerms:   ["hook.transaction-id"]
			changedTerms:     ["journal.event-kind"]
			expectedResult:   "reject"
			rejectionCode:    "journal.lifecycle-collapsed"
		}
		"storage.collector-sole-writer": {
			description:      "Only the collector may issue a DuckDB write request."
			targetDefinition: "#DuckDBWriteRequest"
			preconditions:    ["A component requests a DuckDB mutation."]
			mutationClass:    "non-collector-write"
			preservedTerms:   ["run.id"]
			changedTerms:     ["storage.writer"]
			expectedResult:   "reject"
			rejectionCode:    "storage.non-collector-writer"
		}
		"policy.telemetry-recommendation-orthogonal": {
			description:      "Telemetry health and recommendation are independent fields; no state implies a recommendation."
			targetDefinition: "#PolicyAssessment"
			preconditions:    ["A policy assessment is projected."]
			mutationClass:    "couple-policy-axes"
			preservedTerms:   ["telemetry.state"]
			changedTerms:     ["policy.recommendation"]
			expectedResult:   "accept"
			rejectionCode:    null
		}
	}
}
