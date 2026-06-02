package lifecycle

#ValidationCommand: {
	cmd:    string
	status: "pass" | "fail" | "skipped"

	summary?: string
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

	notes?: [...string]
}
