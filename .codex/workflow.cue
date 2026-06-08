package codex

#CodexHook: {
	session_id?:      string
	transcript_path?: string | null
	cwd?:             string
	hook_event_name?: string
	model?:           string
	turn_id?:         string
	tool_name:        *"" | string
	tool_use_id?:     string
	permission_mode?: string
	tool_input: *{} | _
	tool_response?: _
	...
}

#NonEmptyString: string & =~"(?s).+"

#CommandToolInput: ({
	command:  #NonEmptyString
	cmd?:     _|_
	_command: command
	...
} | {
	command?: _|_
	cmd:      #NonEmptyString
	_command: cmd
	...
})

#CommandHook: #CodexHook & {
	tool_name:  "Bash" | "command"
	tool_input: #CommandToolInput
}

#BaseChecks: [
	"cue vet workspace.cue",
	"cue eval workspace.cue >/dev/null",
	"cue vet .codex/workflow.cue",
	"cue eval .codex/workflow.cue >/dev/null",
]

#CloseoutTask: {
	domain:   string
	task:     string
	reason:   string
	required: bool | *true
}

#CloseoutPolicy: {
	required: [...#CloseoutTask] | *[
		{
			domain: "git"
			task:   "git.closeout"
			reason: "final repository state and diff summary"
		},
		{
			domain: "chezmoi"
			task:   "chezmoi.closeout"
			reason: "managed source/rendered impact summary"
		},
	]

	output: {
		fields: [...string] | *[
			"selectedDomain",
			"matchedSurface",
			"filesChanged",
			"validations",
			"git",
			"chezmoi",
			"handoff",
		]
	}
}

#Workflow: {
	checks: [...string] | *#BaseChecks
	closeout: #CloseoutPolicy
}

workflow: #Workflow & {}
