package hookrail

#SessionStartInput: #CommonInput & {
	hook_event_name: "SessionStart"
	source:          "startup" | "resume" | "clear" | "compact"
}

#UserPromptSubmitInput: #CommonInput & {
	hook_event_name: "UserPromptSubmit"
	prompt:          string
	turn_id:         string
	agent_id?:       string
	agent_type?:     string
}

#PostToolUseInput: #CommonInput & {
	hook_event_name: "PostToolUse"
	turn_id:         string
	tool_name:       string
	tool_use_id:     string
	tool_input:      _
	tool_response:   _
	agent_id?:       string
	agent_type?:     string
}

#StopInput: #CommonInput & {
	hook_event_name:        "Stop"
	turn_id:                string
	last_assistant_message: string | null
	stop_hook_active:       bool
}

#HookInput: #SessionStartInput | #UserPromptSubmitInput | #PostToolUseInput | #StopInput

hookInput: #HookInput
