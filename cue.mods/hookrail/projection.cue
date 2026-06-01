package hookrail

#GitCloseoutReason: "Before final summary, complete git closeout.\n\nUse the git-workflow procedure:\n\n1. Inspect `git status --short`.\n2. Inspect unstaged and staged diffs.\n3. Stage only files directly related to this completed task.\n4. Verify the staged diff.\n5. Generate an accurate Conventional Commit message from the staged diff.\n6. Commit using configured Git MCP write tools when available; otherwise use shell git.\n7. Check final git status.\n8. Then print the final summary with commit SHA, staged/committed files, and validation commands/results.\n\nDo not print the final task summary until the commit succeeds, or until you clearly explain why committing is impossible."

#HookProjection: {
	input: hookInput

	_thresholds: hookInput.hookrail.thresholds | *#Thresholds

	_payloadChars: *0 | int
	if hookInput.hook_event_name == "UserPromptSubmit" {
		_payloadChars: len(hookInput.prompt)
	}
	if hookInput.hook_event_name == "Stop" {
		if hookInput.last_assistant_message != null {
			_payloadChars: len(hookInput.last_assistant_message)
		}
	}
	if hookInput.hookrail.payloadChars != null {
		_payloadChars: hookInput.hookrail.payloadChars
	}

	_payloadClass: *"small" | #PayloadClass
	if hookInput.hook_event_name == "UserPromptSubmit" && _payloadChars >= _thresholds.promptOversizedChars {
		_payloadClass: "oversized"
	}
	if hookInput.hook_event_name == "UserPromptSubmit" && _payloadChars >= _thresholds.promptLargeChars && _payloadChars < _thresholds.promptOversizedChars {
		_payloadClass: "large"
	}
	if hookInput.hook_event_name == "PostToolUse" && _payloadChars >= _thresholds.toolLargeChars {
		_payloadClass: "large"
	}
	if hookInput.hook_event_name == "Stop" && _payloadChars >= _thresholds.toolLargeChars {
		_payloadClass: "large"
	}

	_commitBeforeSummary: hookInput.hookrail.env.commitBeforeSummary

	_userOptedOut: hookInput.hookrail.env.userOptedOut

	_gitIsRepo: hookInput.hookrail.git.isRepo

	_gitDirty: hookInput.hookrail.git.dirty

	_closeoutEvidenceExists: hookInput.hookrail.closeout.evidenceExists

	_priorTraceHeadChanged: hookInput.hookrail.closeout.priorTraceHeadChanged

	_stopActive: *false | bool
	if hookInput.hook_event_name == "Stop" {
		_stopActive: hookInput.stop_hook_active
	}

	_closeoutRequired: _commitBeforeSummary && !_userOptedOut && hookInput.hook_event_name == "Stop" && _gitIsRepo && _gitDirty && !_closeoutEvidenceExists && !_priorTraceHeadChanged && !_stopActive
	_stopRecursionGuard: hookInput.hook_event_name == "Stop" && _stopActive

	_agentText: *null | string
	if _closeoutRequired {
		_agentText: #GitCloseoutReason
	}
	if _stopRecursionGuard {
		_agentText: "hookrail: git closeout gate already active; continuing without repeat block."
	}
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.frameText != null {
		_agentText: hookInput.hookrail.frameText
	}
	if hookInput.hook_event_name == "UserPromptSubmit" && _payloadClass != "small" {
		_agentText: "hookrail: prompt payload is \(_payloadClass) (\(_payloadChars) chars). Prefer compact handoff/frame before continuing long sessions."
	}
	if hookInput.hook_event_name == "PostToolUse" && _payloadClass != "small" {
		_agentText: "hookrail: large tool response captured out-of-band candidate (\(_payloadChars) chars). Injecting bounded summary only."
	}

	output: _output

	_output: #HookOutput
	if _closeoutRequired {
		_output: #StopOutput & {
			decision: "block"
			reason:   #GitCloseoutReason
		}
	}
	if !_closeoutRequired && _stopRecursionGuard {
		_output: #StopOutput & {
			continue:      true
			systemMessage: "hookrail: git closeout gate already active; continuing without repeat block."
		}
	}
	if hookInput.hook_event_name == "Stop" && !_closeoutRequired && !_stopRecursionGuard {
		_output: #StopOutput & {
			continue: true
		}
	}
	if hookInput.hook_event_name == "SessionStart" {
		_output: #ContextHookOutput & {
			continue: true
			hookSpecificOutput: {
				hookEventName: "SessionStart"
				if _agentText != null {
					additionalContext: _agentText
				}
			}
		}
	}
	if hookInput.hook_event_name == "UserPromptSubmit" {
		_output: #ContextHookOutput & {
			continue: true
			hookSpecificOutput: {
				hookEventName: "UserPromptSubmit"
				if _agentText != null {
					additionalContext: _agentText
				}
			}
			if _payloadClass == "oversized" {
				systemMessage: _agentText
			}
		}
	}
	if hookInput.hook_event_name == "PostToolUse" {
		_output: #ContextHookOutput & {
			continue: true
			hookSpecificOutput: {
				hookEventName: "PostToolUse"
				if _agentText != null {
					additionalContext: _agentText
				}
			}
		}
	}

	capture: _capture

	_capture: #CaptureDecision & {
		persist: hookInput.hook_event_name == "UserPromptSubmit" || hookInput.hook_event_name == "Stop" || (hookInput.hook_event_name == "PostToolUse" && _payloadClass != "small") || (hookInput.hook_event_name == "SessionStart" && _agentText != null)
		reason: *"hookrail-projection" | string
		if hookInput.hook_event_name == "UserPromptSubmit" {
			reason: "prompt-metadata"
		}
		if hookInput.hook_event_name == "PostToolUse" {
			reason: "tool-output-budget"
		}
		if hookInput.hook_event_name == "SessionStart" {
			reason: "session-start-frame"
		}
		if hookInput.hook_event_name == "Stop" && !_closeoutRequired && !_stopRecursionGuard {
			reason: "stop-closeout"
		}
		if _closeoutRequired {
			reason: "git-closeout-required"
		}
		if _stopRecursionGuard {
			reason: "git-closeout-recursion-guard"
		}
		fileStem: _fileStem
	}

	_fileStem: *"hook" | string
	if hookInput.hook_event_name == "SessionStart" {
		_fileStem: "session-start"
	}
	if hookInput.hook_event_name == "UserPromptSubmit" {
		_fileStem: "user-prompt-submit"
	}
	if hookInput.hook_event_name == "PostToolUse" {
		_fileStem: "post-tool-use"
	}
	if hookInput.hook_event_name == "Stop" {
		_fileStem: "stop"
	}

	manifest: #HookManifest & {
		schema:         "hookrail.manifest.v1"
		hookEventName:  hookInput.hook_event_name
		sessionID:      hookInput.session_id
		turnID:         _turnID
		cwd:            hookInput.cwd
		model:          hookInput.model
		transcriptPath: hookInput.transcript_path
		payload: {
			chars: _payloadChars
			class: _payloadClass
		}
		capture: _capture
		agentFeed: {
			inject:      _agentText != null
			budgetChars: _thresholds.agentFeedChars
			if _agentText != null {
				text: _agentText
			}
		}
		output: _output
	}

	_turnID: *"session" | string
	if hookInput.turn_id != _|_ {
		_turnID: hookInput.turn_id
	}
}

#SafeFallback: #SafeFallbackOutput
