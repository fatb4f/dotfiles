package hookrail

#SessionStartFrame: {
	schema: "hookrail.session_start_frame.v1"
	source: "startup" | "resume" | "clear" | "compact"
	cwd:    string
	git:    #GitFacts
	hints:  #RepoHints
	text:   string
}

#ContextFrameInput: {
	schema:      "hookrail.context_frame_input.v1"
	generatedAt: string
	sessionID:   string
	turnID:      string
	source:      "startup" | "resume" | "clear" | "compact"
	cwd:         string
	git:         #GitFacts
	hints:       #RepoHints
}
