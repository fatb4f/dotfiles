package workspace

import (
	"encoding/json"
	"strings"
	"tool/exec"
	"tool/file"
)

// #CodexHookInput is intentionally permissive.
// Codex hook payloads are event-specific; this schema types the stable fields
// and leaves tool-specific payloads open.
#CodexHookInput: {
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

// Bash and apply_patch both expose tool_input.command in Codex hooks.
#CommandToolInput: {
	command!: string
	...
}

#ForbiddenHit: {
	surface: string
	pattern: string
}

command: preToolUse: {
	stdin: file.Read & {
		filename: "/dev/stdin"
		contents: string
	}

	hook: #CodexHookInput
	hook: json.Unmarshal(stdin.contents)

	// Run the CUE checks declared by constraints.workflow.cue.checks.
	cueChecks: {
		for i, check in constraints.workflow.cue.checks {
			"\(i)": exec.Run & {
				cmd: ["bash", "-lc", check]
			}
		}
	}

	// Observe pre-mutation git state.
	if constraints.workflow.git.required {
		gitBefore: {
			for i, check in constraints.workflow.git.before {
				"\(i)": exec.Run & {
					cmd: ["bash", "-lc", check]
				}
			}
		}
	}

	// Observe pre-mutation chezmoi state.
	if constraints.workflow.chezmoi.required {
		chezmoiBefore: {
			for i, check in constraints.workflow.chezmoi.before {
				"\(i)": exec.Run & {
					cmd: ["bash", "-lc", check]
				}
			}
		}
	}

	// Prevent destructive commands before they execute.
	if (hook & {tool_input: #CommandToolInput}) != _|_ {
		commandText: hook.tool_input.command

		forbiddenHits: [
			for forbidden in constraints.workflow.git.forbidden
			if strings.Contains(commandText, forbidden) {
				surface: "git"
				pattern: forbidden
			},
			for forbidden in constraints.workflow.chezmoi.forbidden
			if strings.Contains(commandText, forbidden) {
				surface: "chezmoi"
				pattern: forbidden
			},
		]

		if len(forbiddenHits) > 0 {
			block: exec.Run & {
				cmd: [
					"bash",
					"-lc",
					"echo 'blocked by .codex/constraints.cue: forbidden \(forbiddenHits[0].surface) command: \(forbiddenHits[0].pattern)' >&2; exit 2",
				]
			}
		}
	}
}

command: postToolUse: {
	stdin: file.Read & {
		filename: "/dev/stdin"
		contents: string
	}

	hook: #CodexHookInput
	hook: json.Unmarshal(stdin.contents)

	// Re-run CUE authority checks after mutation.
	cueChecks: {
		for i, check in constraints.workflow.cue.checks {
			"\(i)": exec.Run & {
				cmd: ["bash", "-lc", check]
			}
		}
	}

	// Observe post-mutation git state.
	if constraints.workflow.git.required {
		gitAfter: {
			for i, check in constraints.workflow.git.after {
				"\(i)": exec.Run & {
					cmd: ["bash", "-lc", check]
				}
			}
		}
	}

	// Observe post-mutation chezmoi state.
	if constraints.workflow.chezmoi.required {
		chezmoiAfter: {
			for i, check in constraints.workflow.chezmoi.after {
				"\(i)": exec.Run & {
					cmd: ["bash", "-lc", check]
				}
			}
		}
	}
}
