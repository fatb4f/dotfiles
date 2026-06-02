package lifecycle

#ValidationCommand: {
	cmd:    string
	status: "pass" | "fail" | "skipped"

	summary?: string
}

#TokenUsageEvidenceSchemaVersion: "cuerail.tokenUsageEvidence.v2"
#TokenUsageEvidenceStatus:        "ok" | "partial" | "unavailable" | "parse_failed"
#TokenUsageEvidenceSourceKind:    "codex-script-log" | "codex-session-artifact" | "chat-paste" | "file" | "unknown"
#TokenUsageEvidenceTimestamp:     =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"

#TokenUsageEvidence: {
	schemaVersion: #TokenUsageEvidenceSchemaVersion

	run: {
		id:       string
		exitCode: int & >=0
		status:   "ok" | "failed"
	}

	source: {
		kind:        #TokenUsageEvidenceSourceKind
		path?:       string
		extractedAt: #TokenUsageEvidenceTimestamp
	}

	git?: {
		commit?: =~"^[0-9a-f]{40}$"
	}

	status:   #TokenUsageEvidenceStatus
	degraded: bool

	usage?: {
		total?:     int & >=0
		input?:     int & >=0
		cached?:    int & >=0
		output?:    int & >=0
		reasoning?: int & >=0
	}

	observed?: {
		line: string
	}

	notes: [...string]
}

#ProcessTokenUsage: {
	available: bool
	status:     #TokenUsageEvidenceStatus
	degraded:   bool

	evidence?: #TokenUsageEvidence
	notes:     [...string]

	if available == true {
		evidence: #TokenUsageEvidence
	}
}

#ProcessLifecycleProof: {
	schemaVersion: "cuerail.processLifecycleProof.v1"

	slice: {
		id:        string
		objective: string
	}

	session: {
		id?:      string
		logPath?: string
	}

	git: {
		commit?:    string
		dirtyState?: string
	}

	selection: {
		workflow:   string
		projection: string
		carryOver?: string

		domainCards: [...string]
	}

	route: {
		firstContactGuardFollowed: bool

		requiredLoads: [...string]
		loadedPaths:   [...string]

		forbiddenLoads:         [...string]
		forbiddenLoadViolations: [...string]
	}

	change: {
		filesChanged: [...string]
		scope:        string
	}

	validate: {
		commands: [...#ValidationCommand]
	}

	closeout: {
		status: "committed" | "not-committed" | "blocked"

		reason?: string
	}

	tokenUsage?: #ProcessTokenUsage

	notes?: [...string]
}
