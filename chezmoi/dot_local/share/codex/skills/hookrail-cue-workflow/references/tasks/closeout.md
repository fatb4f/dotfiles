# Task: hookrail-cue.closeout

Produce CUE/Hookrail handoff for repo close-out.

Git staging and commits are handled by `git-workflow`.

## Commands

```sh
rg --files cue.mods/hookrail
cue vet cue.mods/hookrail
```

Conditional:

```sh
cue fmt cue.mods/hookrail
fd . cue.mods/hookrail/fixtures
```

## Procedure

1. Identify touched CUE/fixture files.
2. Identify task class: contract, projection, feed, manifest, or validation.
3. Run bounded validation if needed.
4. Report whether Git close-out can proceed.
5. Hand Git commit work to `git-workflow`.

## Rules

- Do not stage files.
- Do not commit.
- Do not edit files unless validation requires `cue fmt`.
- Do not inspect shell-wrap unless the task crossed into execution adapters.
- Do not claim validation without command output.

## Output

Report only:

- CUE files touched
- fixtures touched
- validation commands/result
- blockers for Git close-out
- whether Git close-out can proceed

## Stop condition

Stop when CUE/Hookrail state is summarized for root AGENTS.md or `git-workflow`.
