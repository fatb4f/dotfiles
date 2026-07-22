package positive

import profile "github.com/fatb4f/dotfiles/codexprofile"

Source=source: profile.#SourceIdentity & {
	kind:       "rollout"
	sourceID:   "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
	generation: 0
}

Coordinate=coordinate: profile.#SourceCoordinate & {source: Source, sourceOffset: 128}

Adapter=adapter: profile.#AdapterIdentity & {
	adapterID: "rollout.v0"
	version:   "0.1.0"
	digest:    "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
}

usage: profile.#UsageObservation & {
	schema:                    "codex-usage-observation.v0"
	observationID:             "018f1234-5678-7abc-8def-0123456789ab"
	threadID:                  "thread-1"
	rolloutOrdinal:            4
	usageObservationIndex:     2
	eventTimestamp:            "2026-07-22T12:00:00Z"
	reportedInputTokens:       100
	cachedInputTokens:         60
	cacheWriteInputTokens:     5
	freshInputTokens:          40
	outputTokens:              10
	reasoningOutputTokens:     2
	totalTokens:               110
	estimatedContextPressure:  {state: "observed", value: 90}
	nativeActiveContextTokens: {state: "unavailable", reason: "not emitted by rollout"}
	modelContextWindow:        {state: "observed", value: 258400}
	coordinate:                Coordinate
	adapter:                   Adapter
}

policy: profile.#PolicyAssessment & {
	schema:         "codex-policy-assessment.v0"
	telemetryState: "degraded"
	recommendation: "none"
	reasons:        ["native active context unavailable"]
	projection: {
		projectionID: "policy.v0"
		version:      "0.1.0"
		digest:       "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
	}
	advisoryOnly: true
}

write: profile.#DuckDBWriteRequest & {
	schema:    "codex-duckdb-write.v0"
	writer:    "collector"
	operation: "append_normalized"
	runID:     "018f1234-5678-7abc-8def-0123456789ac"
}
