package codex

import (
	"encoding/json"
	"tool/exec"
)

#HookInput: {
	payload: *"{}" | string @tag(hook)

	hook: #CodexHook
	hook: json.Unmarshal(payload)

	if hook.tool_name == "command" {
		commandHook: hook & #CommandHook

		forceCommandPayload: exec.Run & {
			cmd: [
				"bash",
				"-lc",
				"test -n \"$1\" || { echo 'command hook payload requires non-empty tool_input.command or tool_input.cmd' >&2; exit 2; }",
				"--",
				commandHook.tool_input._command,
			]
		}
	}
}

#RunChecks: {
	checks: [...string]
	for i, check in checks {
		"\(i)": exec.Run & {
			cmd: ["bash", "-lc", check]
		}
	}
}

command: validate: {
	#HookInput

	cueChecks: #RunChecks & {
		checks: workflow.checks
	}
}
