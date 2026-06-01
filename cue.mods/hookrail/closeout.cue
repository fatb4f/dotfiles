package hookrail

#CloseoutPacket: {
	schema:      "hookrail.closeout_packet.v1"
	generatedAt: string
	sessionID:   string
	turnID:      string
	cwd:         string
	git: {
		isRepo:            bool
		dirty:             bool
		head:              string | null
		facts?:            #GitFacts
		changedFileSample: [...{
			path:   string
			status: string
		}]
		truncated: bool
	}
	validation: #ValidationSurface
	stopDecisionInput: {
		commitBeforeSummary:    bool
		userOptedOut:           bool
		closeoutEvidenceExists: bool
		priorTraceHeadChanged:  bool
		stopHookActive:         bool
		sessionRisk?:           #SessionRisk
		stopPolicyAction?:      #HookrailStopPolicyAction
		willBlock:              bool
	}
	output: #StopOutput
}
