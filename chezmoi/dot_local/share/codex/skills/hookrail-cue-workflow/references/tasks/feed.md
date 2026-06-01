# Task: hookrail-cue.feed

Edit agent-feed shape or sentinel behavior.

## Common files

```text
cue.mods/hookrail/agent_feed.cue
cue.mods/hookrail/feed_proof.cue
cue.mods/hookrail/projection.cue
cue.mods/hookrail/fixtures/*feed*.json
```

## Commands

Before edit:

```sh
rg "AgentFeed|feedSentinel|stdout.systemMessage|stdout.additionalContext|context_frame|compact_report" cue.mods/hookrail
```

After edit:

```sh
cue fmt cue.mods/hookrail
cue vet cue.mods/hookrail
```

## Procedure

1. Identify feed channel/status/payload behavior.
2. Edit feed contract or projection branch.
3. Update feed fixtures only when expected behavior changes.
4. Run `cue fmt`.
5. Run `cue vet`.

## Rules

- Preferred feed channel is contract-level.
- Do not revive legacy feed behavior unless explicitly requested.
- Do not edit shell adapter implementation here.
- Do not stage or commit.

## Output

Report only:

- feed behavior changed
- files changed
- fixtures changed, if any
- validation result
- blocker, if any

## Stop condition

Stop after validation or blocker report.
