package hookrail

#PreferredAgentFeedChannel: "stdout.systemMessage"

#LegacyAgentFeedChannel: "stdout.additionalContext"

#AgentFeedChannel: #PreferredAgentFeedChannel | #LegacyAgentFeedChannel

#AgentFeedStatus: "not_attempted" | "emitted" | "invalid_output"

#AgentFeedPayloadKind: "none" | "context_frame" | "feed_sentinel" | "compact_report"

#AgentFeedSource: #HookName

#AgentFeed: {
	enabled: bool
	channel?: #AgentFeedChannel
	status: #AgentFeedStatus
	payloadKind: #AgentFeedPayloadKind
	bytes?: int & >=0
	source?: #AgentFeedSource
	sentinel?: string
}
