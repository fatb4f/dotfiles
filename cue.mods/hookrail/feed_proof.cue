package hookrail

#HookFeedProofInput: {
	hookEventName: #HookName | *"SessionStart"
	sentinel:      string
	emitted:       bool
	observedInTranscript: bool
	reportedByAgent:      bool
	toolCallBeforeReport: *false | bool
	requiredToolCallOccurred: *false | bool
	extraToolCallBeforeReport: *false | bool
}

#HookFeedProof: {
	schema: "hookrail.feedProof.v1"

	hookEventName: #HookName
	channel:       #AgentFeedChannel

	sentinel: string

	emitted:                  bool
	observedInTranscript:     bool
	reportedByAgent:          bool
	toolCallBeforeReport:     bool
	requiredToolCallOccurred: bool
	extraToolCallBeforeReport: bool

	result: "green" | "yellow" | "red"

	if emitted && observedInTranscript && reportedByAgent && !extraToolCallBeforeReport && (hookEventName != "PostToolUse" || requiredToolCallOccurred) {
		result: "green"
	}

	if emitted && observedInTranscript && !reportedByAgent && !extraToolCallBeforeReport && (hookEventName != "PostToolUse" || requiredToolCallOccurred) {
		result: "yellow"
	}

	if !emitted || !observedInTranscript || extraToolCallBeforeReport || (hookEventName == "PostToolUse" && !requiredToolCallOccurred) {
		result: "red"
	}
}
