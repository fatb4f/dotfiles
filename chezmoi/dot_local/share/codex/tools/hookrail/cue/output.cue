package hookrail

#SessionStartOutput: {
	continue?: bool
	hookSpecificOutput?: {
		hookEventName: "SessionStart"
		additionalContext?: string
	}
	stopReason?:     string
	suppressOutput?: bool
	systemMessage?:  string
}

#UserPromptSubmitOutput: {
	continue?: bool
	decision?: "block"
	reason?: string
	hookSpecificOutput?: {
		hookEventName: "UserPromptSubmit"
		additionalContext?: string
	}
	stopReason?:     string
	suppressOutput?: bool
	systemMessage?:  string
}

#PostToolUseOutput: {
	continue?: bool
	decision?: "block"
	reason?: string
	hookSpecificOutput?: {
		hookEventName: "PostToolUse"
		additionalContext?: string
		updatedMCPToolOutput?: _
	}
	stopReason?:     string
	suppressOutput?: bool
	systemMessage?:  string
}

#StopOutput: {
	continue?: bool
	decision?: "block"
	reason?: string
	stopReason?:     string
	suppressOutput?: bool
	systemMessage?:  string
}

#HookOutput: #SessionStartOutput | #UserPromptSubmitOutput | #PostToolUseOutput | #StopOutput
