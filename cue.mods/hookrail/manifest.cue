package hookrail

#HookManifest: {
	schema:         "hookrail.manifest.v1"
	hookEventName:  #HookName
	sessionID:      string
	turnID:         string
	cwd:            string
	model:          string
	transcriptPath: string | null

	payload: {
		chars: int & >=0
		class: #PayloadClass
	}

	capture: #CaptureDecision

	agentFeed: #AgentFeed
	output:    #HookOutput
}

#CaptureDecision: {
	persist:  bool
	reason:   string
	fileStem: string
}

#FailureManifest: {
	schema:    "hookrail.failure_manifest.v1"
	timestamp: string
	sessionID: string
	turnID:    string
	reason:    string
}
