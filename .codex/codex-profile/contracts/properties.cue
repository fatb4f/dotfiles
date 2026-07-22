package codexprofile

#PropertyMutationClass:
	"duplicate-coordinate" |
		"same-path-source-incarnation" |
		"replace-admitted-raw" |
		"elevate-authority" |
		"collapse-unavailable-to-null" |
		"timestamp-ordering" |
		"invalid-freshness" |
		"invalid-token-arithmetic" |
		"malformed-source-token-value" |
		"duplicate-diagnostic-code" |
		"replayed-strict-qualification" |
		"adapter-version-evolution" |
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
		"source.incarnation-generation": {
			description:      "A same-path source replacement, truncation below the durable watermark, or checkpoint anchor mismatch receives a new source generation before reading."
			targetDefinition: "#SourceIdentity"
			preconditions:    ["A rollout path already has an admitted watermark."]
			mutationClass:    "same-path-source-incarnation"
			preservedTerms:   ["source.id"]
			changedTerms:     ["source.generation"]
			expectedResult:   "accept"
			rejectionCode:    null
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
		"usage.malformed-source-token-value": {
			description:      "Malformed token values from source evidence remain diagnostics and are not normalized as zero-valued usage."
			targetDefinition: "#UsageObservation"
			preconditions:    ["A source token usage object contains a present malformed token field."]
			mutationClass:    "malformed-source-token-value"
			preservedTerms:   ["source.coordinate"]
			changedTerms:     ["usage.field"]
			expectedResult:   "reject"
			rejectionCode:    "usage.invalid-accounting"
		}
		"diagnostic.identity-scoped": {
			description:      "Multiple diagnostics at one source coordinate with the same code remain separately admissible by scope or ordinal."
			targetDefinition: "#RawObservationEnvelope"
			preconditions:    ["One source coordinate emits more than one finding with the same diagnostic code."]
			mutationClass:    "duplicate-diagnostic-code"
			preservedTerms:   ["source.coordinate"]
			changedTerms:     ["diagnostic.scope", "diagnostic.ordinal"]
			expectedResult:   "accept"
			rejectionCode:    null
		}
		"strict.persisted-qualification": {
			description:      "Strict qualification reads persisted unresolved diagnostics for the active source and adapter version."
			targetDefinition: "#UsageObservation"
			preconditions:    ["A strict diagnostic has already been admitted for the active source and adapter version."]
			mutationClass:    "replayed-strict-qualification"
			preservedTerms:   ["source.coordinate", "adapter.identity"]
			changedTerms:     ["qualification.invocation"]
			expectedResult:   "reject"
			rejectionCode:    "usage.invalid-accounting"
		}
		"usage.adapter-version-addressed": {
			description:      "Normalized usage observations are addressed by adapter identity so corrected normalization can coexist with prior output."
			targetDefinition: "#UsageObservation"
			preconditions:    ["A source coordinate has already been normalized by a previous adapter version."]
			mutationClass:    "adapter-version-evolution"
			preservedTerms:   ["source.coordinate"]
			changedTerms:     ["adapter.identity"]
			expectedResult:   "accept"
			rejectionCode:    null
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
