## Read

This confirms the prior stop/review decision, but with a stronger reason:

```text id="fbkyth"
The immediate constraint is no longer repo design quality.
The immediate constraint is Codex rolling-window burn.
```

The audit shows a roughly **1,000× amplification** between estimated user input tokens and conservative usage delta: `37,507` estimated user input tokens versus `37,847,965+` conservative token delta in the 5h window. The uploaded analysis correctly diagnoses this as **session/context replay + tool/event loops**, not merely long prompts. 

## Updated priority order

```text id="b1jj0x"
1. Freeze repo implementation.
2. Stop resume-heavy Codex usage.
3. Inspect top runaway session files.
4. Add Codex usage guardrail v3.
5. Only then return to hooks / issue cleanup / chezmoi closeout.
```

So the previous plan changes from:

```text id="gwbcm3"
Hook stabilization + issue inventory
```

to:

```text id="m9jayp"
Codex usage guardrail v3 first
```

Because any further repo work through the current Codex pattern is itself unsafe.

---

## Current diagnosis

```text id="yfqsr3"
rolling 5h delta: ~38.3M tokens
user turns in window: 75
largest snapshot: 12.6M
June 1 daily delta: ~76.3M
top session files dominate burn
```

The worst shape is:

```text id="f3cucp"
few user turns
+ huge event count
+ huge delta tokens
= context/tool loop, not normal work
```

The suspicious session:

```text id="qqhcm1"
/home/_404/.local/share/codex/sessions/2026/06/01/rollout-2026-06-01T07-32-18-019e82f4-c118-7ce3-9690-3ca1e78506e4.jsonl
```

Signal:

```text id="pk3rmn"
5 user turns
848 events
12,590,949 delta tokens
≈ 2.5M delta tokens / user turn
```

That is the first forensic target.

---

## Immediate operating policy

### Hard freeze

```text id="uq658x"
Do not continue:
- router design
- agents.cue
- hook expansion
- issue creation
- frame comparison
- chezmoi closeout implementation
```

Until the usage guard can classify and stop runaway sessions.

### Resume policy

```text id="d14v4r"
resume --last default: forbidden
```

Allowed only when:

```text id="yd5o7b"
same task
same repo state
same bounded slice
previous session below threshold
```

Default workflow should become:

```text id="u810ga"
fresh Codex session
+ compact task frame
+ exact files
+ no broad repo scan
+ explicit stop threshold
```

---

## Guardrail v3 target

Add a report like:

```text id="3me31g"
#CodexUsageGuard

accepted: false

violations:
  - rolling_5h_delta_tokens_exceeded
  - session_delta_tokens_exceeded
  - events_per_session_exceeded
  - resume_runaway_suspected

recommended_action:
  - stop Codex work
  - inspect top runaway session
  - restart fresh with compact handoff
```

Thresholds:

```text id="ips8dr"
rolling 5h:
  warn: 5M delta tokens
  stop: 10M delta tokens

session:
  warn: 750k delta tokens
  stop: 1.5M delta tokens
  max events: 400
  max user turns: 8
  max prompt estimate: 8k
```

Your current state is already beyond hard stop:

```text id="i3h5iv"
current rolling 5h: ~38M
stop threshold:     10M
```

---

## Codex-ready next slice

```text id="4jiq68"
Implement Codex usage audit v3. Do not modify dotfiles hooks, agents.cue, skill router files, GitHub issues, or chezmoi lifecycle code.

Context:
- Current audit v2 shows runaway Codex usage.
- Last 5h conservative delta is ~38M tokens.
- User input estimate is only ~37.5k tokens.
- Burn is concentrated in a small number of session JSONL files.
- The likely failure mode is long/resumed sessions plus repeated context snapshots and tool/event loops.
- Server-side usage remains authoritative, but local logs are good enough for guardrails.

Task:
Extend the existing Codex usage audit into a guardrail-oriented v3.

Add per-session derived metrics:
- delta_tokens_per_user_turn
- delta_tokens_per_event
- snapshot_growth_rate
- largest_single_delta
- first_snapshot
- last_snapshot
- model_call_count
- tool_call_count
- assistant_turn_count

Add session classification:
- normal
- large_prompt
- long_context
- tool_loop
- resume_runaway
- unknown_runaway

Add policy thresholds:
- rolling5h.warnDeltaTokens = 5_000_000
- rolling5h.stopDeltaTokens = 10_000_000
- rolling5h.maxUserTurns = 40
- session.warnDeltaTokens = 750_000
- session.stopDeltaTokens = 1_500_000
- session.maxEvents = 400
- session.maxUserTurns = 8
- session.maxPromptEstimate = 8_000

Add a final guard report:
- accepted: true/false
- violations
- top offending sessions
- recommended action

Required output commands or modes:
- codex-usage-audit
- codex-usage-guard
- codex-session-top
- codex-session-inspect

Constraints:
- No new router.
- No agents.cue expansion.
- No hook changes.
- No frame runtime.
- No GitHub issue creation.
- No broad repo redesign.
- Keep this as a local usage-control adapter.
```

## Revised project gate

```text id="6p8khi"
Before any more architecture work:

CodexUsageGuard.accepted must be true
OR
the next task must be usage-guard repair only.
```

That gives you the right stop hierarchy:

```text id="4e1zne"
quota/control safety
→ repo review
→ hook stabilization
→ issue collapse
→ chezmoi closeout
→ router only if still justified
```
