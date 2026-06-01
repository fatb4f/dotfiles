package hookrail

#HookOutput: {
	continue?: bool
	decision?: "block"
	reason?: string
	hookSpecificOutput?: {
		hookEventName:     "SessionStart" | "UserPromptSubmit" | "PostToolUse"
		additionalContext?: string
		updatedMCPToolOutput?: _
	}
	stopReason?:     string
	suppressOutput?: bool
	systemMessage?:  string
}

#ContextHookOutput: #HookOutput
#StopOutput: #HookOutput

#SafeFallbackOutput: #StopOutput & {
	continue:       true
	suppressOutput: true
	systemMessage:  string | *"hookrail safe fallback after adapter/CUE failure"
}
