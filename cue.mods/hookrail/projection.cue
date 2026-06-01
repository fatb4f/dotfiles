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

	_sessionRisk: *"normal" | #SessionRisk
	if hookInput.hookrail.sessionRisk != null {
		_sessionRisk: hookInput.hookrail.sessionRisk
	}

	_stopPolicyAction: *"git_closeout_gate" | #HookrailStopPolicyAction
	if hookInput.hook_event_name == "Stop" && _sessionRisk == "warn" {
		_stopPolicyAction: "short_git_closeout_gate"
	}
	if hookInput.hook_event_name == "Stop" && _sessionRisk == "stop" {
		_stopPolicyAction: "block_fresh_session_handoff"
	}

	_gitIsRepo: hookInput.hookrail.git.isRepo

	_gitDirty: hookInput.hookrail.git.dirty

	_closeoutEvidenceExists: hookInput.hookrail.closeout.evidenceExists

	_priorTraceHeadChanged: hookInput.hookrail.closeout.priorTraceHeadChanged

	_stopActive: *false | bool
	if hookInput.hook_event_name == "Stop" {
		_stopActive: hookInput.stop_hook_active
	}

	_closeoutRequired: _commitBeforeSummary && !_userOptedOut && hookInput.hook_event_name == "Stop" && _gitIsRepo && _gitDirty && !_closeoutEvidenceExists && !_priorTraceHeadChanged && !_stopActive && _stopPolicyAction == "git_closeout_gate"
	_stopRecursionGuard: hookInput.hook_event_name == "Stop" && _stopActive
	_sessionRiskHandoff: hookInput.hook_event_name == "Stop" && (_stopPolicyAction == "short_git_closeout_gate" || _stopPolicyAction == "block_fresh_session_handoff")
	_sessionRiskHandoffText: *"" | string
	if hookInput.hook_event_name == "Stop" && _stopPolicyAction == "short_git_closeout_gate" {
		_sessionRiskHandoffText: "hookrail: session risk is elevated; finish in a fresh session instead of running full git closeout here."
	}
	if hookInput.hook_event_name == "Stop" && _stopPolicyAction == "block_fresh_session_handoff" {
		_sessionRiskHandoffText: "hookrail: session risk is high; stop this run and continue in a fresh session."
	}

	_sessionStartStatusSummary: *"clean working tree" | string
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.isRepo && hookInput.hookrail.git.statusSummary != null {
		_sessionStartStatusSummary: hookInput.hookrail.git.statusSummary
	}

	_sessionStartTranscriptPath: *"none" | string
	if hookInput.transcript_path != null {
		_sessionStartTranscriptPath: hookInput.transcript_path
	}

	_sessionStartFeedSentinelText: *"" | string
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.feedSentinel != null {
		_sessionStartFeedSentinelText: "\n  feedSentinel: \(hookInput.hookrail.feedSentinel)"
	}

	_eventFeedSentinelText: *null | string | null
	if hookInput.hook_event_name != "SessionStart" && hookInput.hookrail.feedSentinel != null {
		_eventFeedSentinelText: hookInput.hookrail.feedSentinel
	}

	_sessionStartRepoBranchText: *"none" | string
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.branch != null {
		_sessionStartRepoBranchText: hookInput.hookrail.git.branch
	}

	_sessionStartRepoHeadText: *"none" | string
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.head != null {
		_sessionStartRepoHeadText: hookInput.hookrail.git.head
	}

	_sessionStartFrameGenerated: *false | bool
	_sessionStartFrameSchema: *null | string | null
	_sessionStartFrameText: *null | string | null
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.isRepo && hookInput.hookrail.frameText == null {
		_sessionStartFrameGenerated: true
		_sessionStartFrameSchema: "hookrail.contextFrame.v1"
		_sessionStartFrameText: "schema: hookrail.contextFrame.v1\nsource: SessionStart\nrepo:\n  root: \(hookInput.hookrail.git.root)\n  branch: \(_sessionStartRepoBranchText)\n  head: \(_sessionStartRepoHeadText)\n  dirty: \(hookInput.hookrail.git.dirty)\n  statusSummary: \(_sessionStartStatusSummary)\nsession:\n  id: \(hookInput.session_id)\n  cwd: \(hookInput.cwd)\n  model: \(hookInput.model)\n  transcriptPath: \(_sessionStartTranscriptPath)\(_sessionStartFeedSentinelText)\ninstructions: Use only the bounded repo facts below. Treat traces, manifests, and repo state files as runtime evidence only, not injected memory."
	}

	_agentText: *null | string
	if _closeoutRequired {
		_agentText: #GitCloseoutReason
	}
	if _stopRecursionGuard {
		_agentText: "hookrail: git closeout gate already active; continuing without repeat block."
	}
	if _sessionRiskHandoff {
		_agentText: _sessionRiskHandoffText
	}
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.frameText != null {
		_agentText: hookInput.hookrail.frameText
	}
	if hookInput.hook_event_name == "SessionStart" && _sessionStartFrameText != null {
		_agentText: _sessionStartFrameText
	}
	if hookInput.hook_event_name == "UserPromptSubmit" && _payloadClass != "small" {
		_agentText: "hookrail: prompt payload is \(_payloadClass) (\(_payloadChars) chars). Prefer compact handoff/frame before continuing long sessions."
	}
	if hookInput.hook_event_name == "PostToolUse" && _payloadClass != "small" {
		_agentText: "hookrail: large tool response captured out-of-band candidate (\(_payloadChars) chars). Injecting bounded summary only."
	}

	_feedChannel: *null | string | null
	_feedStatus: *"not_attempted" | #AgentFeedStatus
	_feedPayloadKind: *"none" | #AgentFeedPayloadKind
	_feedBytes: *0 | int
	_feedSentinel: *null | string | null
	if hookInput.hook_event_name == "SessionStart" && _sessionStartFrameText != null && hookInput.hookrail.feedSentinel == null {
		_feedChannel: "stdout.systemMessage"
		_feedStatus: "emitted"
		_feedPayloadKind: "context_frame"
		_feedBytes: len(_agentText)
	}
	if hookInput.hook_event_name == "SessionStart" && _sessionStartFrameText != null && hookInput.hookrail.feedSentinel != null {
		_feedChannel: "stdout.systemMessage"
		_feedStatus: "emitted"
		_feedPayloadKind: "feed_sentinel"
		_feedBytes: len(_agentText)
		_feedSentinel: hookInput.hookrail.feedSentinel
	}
	if hookInput.hook_event_name == "UserPromptSubmit" && hookInput.hookrail.feedSentinel != null {
		_feedChannel: "stdout.systemMessage"
		_feedStatus: "emitted"
		_feedPayloadKind: "feed_sentinel"
		_feedBytes: len(_eventFeedSentinelText)
		_feedSentinel: hookInput.hookrail.feedSentinel
	}
	if hookInput.hook_event_name == "UserPromptSubmit" && _agentText != null && hookInput.hookrail.feedSentinel == null {
		_feedChannel: "stdout.systemMessage"
		_feedStatus: "emitted"
		_feedPayloadKind: "compact_report"
		_feedBytes: len(_agentText)
	}
	if hookInput.hook_event_name == "PostToolUse" && hookInput.hookrail.feedSentinel == null && _agentText != null {
		_feedChannel: "stdout.systemMessage"
		_feedStatus: "emitted"
		_feedPayloadKind: "compact_report"
		_feedBytes: len(_agentText)
	}

	_sessionStartFrameSchema: *null | string | null
	if hookInput.hook_event_name == "SessionStart" && _sessionStartFrameText != null {
		_sessionStartFrameSchema: "hookrail.contextFrame.v1"
	}

	_sessionStartFrameChars: *0 | int
	if hookInput.hook_event_name == "SessionStart" && _sessionStartFrameText != null && _agentText != null {
		_sessionStartFrameChars: len(_agentText)
	}

	_sessionStartGitRoot: *null | string | null
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.isRepo {
		_sessionStartGitRoot: hookInput.hookrail.git.root
	}

	_sessionStartGitBranch: *null | string | null
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.isRepo {
		_sessionStartGitBranch: hookInput.hookrail.git.branch
	}

	_sessionStartGitHead: *null | string | null
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.isRepo {
		_sessionStartGitHead: hookInput.hookrail.git.head
	}

	_sessionStartGitStatusSummary: *null | string | null
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.isRepo {
		_sessionStartGitStatusSummary: _sessionStartStatusSummary
	}

	_sessionStartGitDirty: *false | bool
	if hookInput.hook_event_name == "SessionStart" && hookInput.hookrail.git.isRepo {
		_sessionStartGitDirty: hookInput.hookrail.git.dirty
	}

	_traceRow: #TraceRow & {
		timestamp:       hookInput.hookrail.trace.timestamp
		hookEventName:   hookInput.hook_event_name
		sessionID:       hookInput.session_id
		turnID:          _turnID
		cwd:             hookInput.cwd
		model:           hookInput.model
		transcriptPath:  hookInput.transcript_path
		frameGenerated:  _sessionStartFrameGenerated
		frameSchema:     _sessionStartFrameSchema
		frameChars:      _sessionStartFrameChars
		gitIsRepo:       hookInput.hookrail.git.isRepo
		gitRoot:         _sessionStartGitRoot
		gitBranch:       _sessionStartGitBranch
		gitHead:         _sessionStartGitHead
		gitDirty:        _sessionStartGitDirty
		gitStatusSummary: _sessionStartGitStatusSummary
		feedChannel:     _feedChannel
		feedStatus:      _feedStatus
		feedPayloadKind: _feedPayloadKind
		feedBytes:       _feedBytes
		feedSentinel:    _feedSentinel
		manifestPath:    hookInput.hookrail.trace.manifestPath
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
	if hookInput.hook_event_name == "Stop" && !_closeoutRequired && !_stopRecursionGuard && !_sessionRiskHandoff {
		_output: #StopOutput & {
			continue: true
		}
	}
	if hookInput.hook_event_name == "SessionStart" {
		_output: #ContextHookOutput & {
			continue: true
			if _agentText != null {
				systemMessage: _agentText
			}
			hookSpecificOutput: {
				hookEventName: "SessionStart"
			}
		}
	}
	if hookInput.hook_event_name == "UserPromptSubmit" {
		_output: #ContextHookOutput & {
			continue: true
			hookSpecificOutput: {
				hookEventName: "UserPromptSubmit"
			}
			if _eventFeedSentinelText != null {
				systemMessage: _eventFeedSentinelText
			}
			if _eventFeedSentinelText == null && _payloadClass == "oversized" {
				systemMessage: _agentText
			}
		}
	}
	if _sessionRiskHandoff {
		_output: #StopOutput & {
			decision:     "block"
			reason:       "session-risk-handoff"
			stopReason:   _sessionRiskHandoffText
			systemMessage: _sessionRiskHandoffText
		}
	}
	if hookInput.hook_event_name == "PostToolUse" {
		_output: #ContextHookOutput & {
			continue: true
			if _agentText != null {
				systemMessage: _agentText
			}
			hookSpecificOutput: {
				hookEventName: "PostToolUse"
			}
		}
	}

	capture: _capture

	_feedProof: *null | #HookFeedProof | null
	if hookInput.hookrail.feedProof != null {
		_feedProof: #HookFeedProof & {
			hookEventName:            hookInput.hookrail.feedProof.hookEventName
			channel:                  "stdout.systemMessage"
			sentinel:                 hookInput.hookrail.feedProof.sentinel
			emitted:                  hookInput.hookrail.feedProof.emitted
			observedInTranscript:     hookInput.hookrail.feedProof.observedInTranscript
			reportedByAgent:          hookInput.hookrail.feedProof.reportedByAgent
			toolCallBeforeReport:     hookInput.hookrail.feedProof.extraToolCallBeforeReport
			requiredToolCallOccurred: hookInput.hookrail.feedProof.requiredToolCallOccurred
			extraToolCallBeforeReport: hookInput.hookrail.feedProof.extraToolCallBeforeReport
			if hookInput.hookrail.feedProof.toolCallBeforeReport {
				extraToolCallBeforeReport: true
			}
		}
	}

	_capture: #CaptureDecision & {
		persist: (hookInput.hook_event_name == "UserPromptSubmit" && _payloadClass != "small") || (hookInput.hook_event_name == "Stop" && (_closeoutRequired || _stopRecursionGuard || _sessionRiskHandoff)) || (hookInput.hook_event_name == "PostToolUse" && _payloadClass != "small")
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
		if hookInput.hook_event_name == "Stop" && !_closeoutRequired && !_stopRecursionGuard && !_sessionRiskHandoff {
			reason: "stop-closeout"
		}
		if _sessionRiskHandoff {
			reason: "session-risk-handoff"
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
		agentFeed: #AgentFeed & {
			enabled: *false | bool
			status: *"not_attempted" | #AgentFeedStatus
			payloadKind: *"none" | #AgentFeedPayloadKind
			if hookInput.hook_event_name == "SessionStart" && _sessionStartFrameText != null && hookInput.hookrail.feedSentinel == null {
				enabled: true
				status: "emitted"
				payloadKind: "context_frame"
				channel: "stdout.systemMessage"
				bytes: len(_agentText)
				source: "SessionStart"
			}
			if hookInput.hook_event_name == "SessionStart" && _sessionStartFrameText != null && hookInput.hookrail.feedSentinel != null {
				enabled: true
				status: "emitted"
				payloadKind: "feed_sentinel"
				channel: "stdout.systemMessage"
				bytes: len(_agentText)
				source: "SessionStart"
				sentinel: hookInput.hookrail.feedSentinel
			}
			if hookInput.hook_event_name == "UserPromptSubmit" && hookInput.hookrail.feedSentinel != null {
				enabled: true
				status: "emitted"
				payloadKind: "feed_sentinel"
				channel: "stdout.systemMessage"
				bytes: len(_eventFeedSentinelText)
				source: "UserPromptSubmit"
				sentinel: hookInput.hookrail.feedSentinel
			}
			if hookInput.hook_event_name == "UserPromptSubmit" && _agentText != null && hookInput.hookrail.feedSentinel == null {
				enabled: true
				status: "emitted"
				payloadKind: "compact_report"
				channel: "stdout.systemMessage"
				bytes: len(_agentText)
				source: "UserPromptSubmit"
			}
			if hookInput.hook_event_name == "PostToolUse" && _agentText != null && hookInput.hookrail.feedSentinel == null {
				enabled: true
				status: "emitted"
				payloadKind: "compact_report"
				channel: "stdout.systemMessage"
				bytes: len(_agentText)
				source: "PostToolUse"
			}
		}
		output: _output
	}

	feedProof: _feedProof

	traceRow: _traceRow

	_turnID: *"session" | string
	if hookInput.turn_id != _|_ {
		_turnID: hookInput.turn_id
	}
}

#SafeFallback: #SafeFallbackOutput
