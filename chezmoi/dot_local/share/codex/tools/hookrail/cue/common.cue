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
}
