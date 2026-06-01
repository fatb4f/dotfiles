package hookrail

#CapturePolicy: {
	thresholds: #Thresholds

	persistHooks: [...#HookName]
	persistHooks: *["UserPromptSubmit", "PostToolUse", "Stop"] | [...#HookName]

	redaction: {
		storeRawPrompt:      *false | bool
		storeRawToolOutput:  *false | bool
		storeAssistantText:  *false | bool
	}
}

#PayloadBudget: {
	chars: int & >=0
	class: #PayloadClass
}
