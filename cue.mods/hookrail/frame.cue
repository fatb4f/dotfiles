package hookrail

#ContextFrame: {
	schema: "hookrail.contextFrame.v1"
	source: "SessionStart"
	repo: {
		root:          string
		branch:        string | null
		head:          string | null
		dirty:         bool
		statusSummary: string
	}
	session: {
		sessionID:     string
		cwd:           string
		model:         string
		transcriptPath: string | null
	}
	instructions: string
	text:         string
}

#SessionStartFrame: #ContextFrame

#TraceRow: {
	schema:          "hookrail.trace_row.v1"
	timestamp:       string
	hookEventName:   #HookName
	sessionID:       string
	turnID:          string
	cwd:             string
	model:           string
	transcriptPath:  string | null
	frameGenerated:  bool
	frameSchema:     string | null
	frameChars:      int & >=0
	gitIsRepo:       bool
	gitRoot:         string | null
	gitBranch:       string | null
	gitHead:         string | null
	gitDirty:        bool
	gitStatusSummary: string | null
	manifestPath:    string | null
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
