package hookrail

#HookManifest: {
	schema:        "hookrail.manifest.v1"
	hookEventName: #HookName
	sessionID:     string
	turnID:        string
	cwd:           string
	model:         string
	transcriptPath: string | null

	payload: {
		chars: int & >=0
		class: #PayloadClass
	}

	capture: {
		persist: bool
		reason?: string
		path?:   string
	}

	agentFeed: #AgentFeed

	// Native Codex hook output object.
	output: _
}
