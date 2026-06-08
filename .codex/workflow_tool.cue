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
		commandToolInput: #CommandToolInput & hook.tool_input
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

	base: #RunChecks & {
		checks: #BaseChecks
	}
}
