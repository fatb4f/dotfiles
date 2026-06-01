package hookrail

#HookFeedProofInput: {
	sentinel: string
	emitted: bool
	observedInTranscript: bool
	reportedByAgent: bool
	toolCallBeforeReport: bool
}

#HookFeedProof: {
	schema: "hookrail.feedProof.v1"

	hookEventName: "SessionStart"
	channel:       #AgentFeedChannel

	sentinel: string

	emitted:              bool
	observedInTranscript: bool
	reportedByAgent:      bool
	toolCallBeforeReport: bool

	result: "green" | "yellow" | "red"

	if emitted && observedInTranscript && reportedByAgent && !toolCallBeforeReport {
		result: "green"
	}

	if emitted && observedInTranscript && !reportedByAgent && !toolCallBeforeReport {
		result: "yellow"
	}

	if !emitted || !observedInTranscript || toolCallBeforeReport {
		result: "red"
	}
}
