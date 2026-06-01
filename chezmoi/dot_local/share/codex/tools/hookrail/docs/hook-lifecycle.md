# Hook lifecycle

Initial scope:

```text
SessionStart       -> bounded frame injection / resume warning
UserPromptSubmit   -> turn payload classifier
PostToolUse        -> evidence capture + bounded feedback
Stop               -> closeout handoff
```

Deferred hooks:

```text
PreToolUse
PermissionRequest
PreCompact
PostCompact
SubagentStart
SubagentStop
```

## Control invariant

```text
runtime hook timing is authoritative
CUE describes event/output shape and policy
scripts adapt stdin/stdout and filesystem persistence only
full evidence is persisted out-of-band
Codex receives only bounded additionalContext/systemMessage
```
