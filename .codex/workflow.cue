package codex

#CodexHook: {
	session_id?:       string
	transcript_path?:  string | null
	cwd?:              string
	hook_event_name?:  string
	model?:            string
	turn_id?:          string
	tool_name:         *"" | string
	tool_use_id?:      string
	permission_mode?:  string
	tool_input:        *{} | _
	tool_response?:    _
	...
}

#CommandToolInput: ({
	command!: string
	...
} | {
	cmd!: string
	...
})

#BaseChecks: [
	"cue vet workspace.cue",
	"cue eval workspace.cue >/dev/null",
	"cue vet .codex/workflow.cue",
	"cue eval .codex/workflow.cue >/dev/null",
]
