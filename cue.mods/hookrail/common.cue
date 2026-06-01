package hookrail

#HookName: "SessionStart" | "UserPromptSubmit" | "PostToolUse" | "Stop"

#PermissionMode: "default" | "acceptEdits" | "plan" | "dontAsk" | "bypassPermissions"

#PayloadClass: "small" | "large" | "oversized"

#Thresholds: {
	promptLargeChars:     *50000 | int & >=0
	promptOversizedChars: *100000 | int & >=0
	toolLargeChars:       *50000 | int & >=0
	agentFeedChars:       *2000 | int & >=0
}

#CommonInput: {
	cwd:             string
	hook_event_name: #HookName
	model:           string
	permission_mode: #PermissionMode
	session_id:      string
	transcript_path: string | null
	hookrail:        *#RuntimeFacts | #RuntimeFacts
	...
}

#RuntimeFacts: {
	thresholds?: #Thresholds
	payloadChars: *null | int & >=0 | null
	frameText:    *null | string | null
	env: {
		commitBeforeSummary: *true | bool
		userOptedOut:        *false | bool
	}
	git: {
		isRepo: *false | bool
		dirty:  *false | bool
		head:   *null | string | null
	}
	closeout: {
		evidenceExists:        *false | bool
		priorTraceHeadChanged: *false | bool
	}
	validation?: #ValidationSurface
	gitFacts?: #GitFacts
	repoHints?: #RepoHints
	...
}

#GitFacts: {
	isRepo: bool
	cwd?:   string
	if isRepo {
		root:       string
		name:       string
		branch:     string | null
		head:       string | null
		upstream:   string | null
		unsafeRoot: bool
		clean:      bool
		counts: {
			staged:    int & >=0
			unstaged:  int & >=0
			untracked: int & >=0
		}
		changedSample: [...{
			path:   string
			status: string
		}]
		sampleLimit: int & >=0
		truncated:   bool
		operation: {
			state: "normal" | "merge" | "rebase" | "cherry-pick" | "revert" | "bisect"
		}
		lastCommit: {
			subject: string | null
			date:    string | null
			author:  string | null
		}
	}
	if !isRepo {
		unsafeRoot?: bool
		error?:      string
	}
}

#RepoHints: {
	agentsPath:       string | null
	codexConfigPath:  string | null
	packageFiles: [...string]
}

#ValidationSurface: {
	statuses: [...#ValidationStatus]
}

#ValidationStatus: {
	name:   string
	status: "green" | "yellow" | "red" | "unknown" | "skipped"
	detail?: string
}
