# AGENTS.md

CUE/Hookrail domain router.

## Authority

Use:

```text
chezmoi/dot_local/share/codex/skills/hookrail-cue-workflow/SKILL.md
```

Installed skill name:

```text
hookrail-cue-workflow
```

## Scope

Owns:

```text
Hookrail CUE contracts
hook input/output schemas
feed shape
projection semantics
manifest and closeout packet schemas
fixture-backed CUE validation
```

Does not own:

```text
shell execution adapters
Bashly command implementation
chezmoi apply/materialization
Git staging
Git commits
```

## Task routing

Pick one task. Use `hookrail-cue-workflow/SKILL.md`.

| Task pattern | Skill task |
|---|---|
| inspect CUE module/file layout | `hookrail-cue.discovery` |
| edit Hookrail CUE contracts/schemas | `hookrail-cue.contract` |
| edit projection/gating behavior | `hookrail-cue.projection` |
| edit agent-feed shape or sentinel behavior | `hookrail-cue.feed` |
| edit manifest or closeout packet schemas | `hookrail-cue.manifest` |
| validate CUE changes with fixtures | `hookrail-cue.validate` |
| produce CUE/Hookrail handoff for repo close-out | `hookrail-cue.closeout` |

## Workflow order

```text
hookrail-cue.discovery
→ hookrail-cue.contract
→ hookrail-cue.projection
→ hookrail-cue.feed
→ hookrail-cue.manifest
→ hookrail-cue.validate
→ hookrail-cue.closeout
```

Skip steps only when the task is already narrower.

## Boundaries

- Do not edit shell-wrap executable adapters from this domain.
- Do not edit Bashly config/source from this domain.
- Do not run chezmoi apply from this domain.
- Do not stage or commit from this domain.
- Hand shell adapter work to `shell-wrap/AGENTS.md`.
- Hand Git state and commits to `git-workflow`.

## Stop

Stop after the selected `hookrail-cue-workflow` task report.
