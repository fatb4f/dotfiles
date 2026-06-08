package codex

import (
	"encoding/json"
	"strings"
	"tool/exec"
	"tool/file"
)

// #CodexHook is intentionally permissive.
// Codex hook payloads are event-specific; this keeps the stable fields typed
// while allowing tool-specific payloads to pass through.
#CodexHook: {
	session_id!:       string
	transcript_path?: string | null
	cwd!:             string
	hook_event_name!: string

	model?:           string
	turn_id?:         string
	tool_name?:       string
	tool_use_id?:     string
	permission_mode?: string

	tool_input?:    _
	tool_response?: _
	...
}

#CommandToolInput: {
	command!: string
	...
}

#Workflow: {
	cue: {
		checks: [...string] | *[
			"cue vet workspace.cue",
			"cue vet .codex/workflow.cue",
		]
	}

	git: {
		required: bool | *true
		before: [...string] | *[
			"git status --short",
		]
		after: [...string] | *[
			"git diff --name-only",
			"git status --short",
		]
		forbidden: [...string] | *[
			"git commit",
			"git push",
			"git reset --hard",
		]
	}

	chezmoi: {
		required: bool | *true
		before: [...string] | *[
			"chezmoi status",
		]
		after: [...string] | *[
			"chezmoi diff",
			"chezmoi status",
		]
		forbidden: [...string] | *[
			"chezmoi apply",
			"chezmoi init",
		]
	}
}

workflow: #Workflow & {}

#RunChecks: {
	checks: [...string]
	for i, check in checks {
		"\(i)": exec.Run & {
			cmd: ["bash", "-lc", check]
		}
	}
}

#ReadHook: {
	stdin: file.Read & {
		filename: "/dev/stdin"
		contents: string
	}

	hook: #CodexHook
	hook: json.Unmarshal(stdin.contents)
}

command: ci: {
	cueChecks: #RunChecks & {
		checks: workflow.cue.checks
	}
}

command: preToolUse: {
	#ReadHook

	cueChecks: #RunChecks & {
		checks: workflow.cue.checks
	}

	if workflow.git.required {
		gitBefore: #RunChecks & {
			checks: workflow.git.before
		}
	}

	if workflow.chezmoi.required {
		chezmoiBefore: #RunChecks & {
			checks: workflow.chezmoi.before
		}
	}

	if (hook & {tool_input: #CommandToolInput}) != _|_ {
		commandText: hook.tool_input.command

		gitHits: [
			for forbidden in workflow.git.forbidden
			if strings.Contains(commandText, forbidden) {
				forbidden
			},
		]

		chezmoiHits: [
			for forbidden in workflow.chezmoi.forbidden
			if strings.Contains(commandText, forbidden) {
				forbidden
			},
		]

		if len(gitHits) > 0 {
			blockGit: exec.Run & {
				cmd: [
					"bash",
					"-lc",
					"printf '%s\\n' 'blocked by .codex/workflow.cue: forbidden git command: \(gitHits[0])' >&2; exit 2",
				]
			}
		}

		if len(chezmoiHits) > 0 {
			blockChezmoi: exec.Run & {
				cmd: [
					"bash",
					"-lc",
					"printf '%s\\n' 'blocked by .codex/workflow.cue: forbidden chezmoi command: \(chezmoiHits[0])' >&2; exit 2",
				]
			}
		}
	}
}

command: postToolUse: {
	#ReadHook

	cueChecks: #RunChecks & {
		checks: workflow.cue.checks
	}

	if workflow.git.required {
		gitAfter: #RunChecks & {
			checks: workflow.git.after
		}
	}

	if workflow.chezmoi.required {
		chezmoiAfter: #RunChecks & {
			checks: workflow.chezmoi.after
		}
	}
}
