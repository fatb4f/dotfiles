package hookrail

#AgentFeed: {
	inject:      bool
	budgetChars: int & >=0
	text?:       string
}

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
