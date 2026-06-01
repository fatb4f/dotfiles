# AGENTS.md

Shell-wrap domain router.

## Authority

Use:

```text
chezmoi/dot_local/share/codex/skills/bashly-workflow/SKILL.md
```

Installed skill name:

```text
bashly-workflow
```

## Scope

Owns:

```text
Bashly config
Bashly source scripts
command dispatch
generated shell adapter boundaries
executable Hookrail adapters
local shell validation
```

Does not own:

```text
Hookrail CUE contracts
Hookrail feed shape
Hookrail projection semantics
Git staging
Git commits
```

## Task routing

Pick one task. Use `bashly-workflow/SKILL.md`.

| Task pattern | Skill task |
|---|---|
| inspect Bashly config/source layout | `bashly.discovery` |
| edit Bashly config or source scripts | `bashly.edit` |
| validate shell source and Bashly project | `bashly.validate` |
| regenerate Bashly output | `bashly.generate` |
| inspect executable Hookrail adapter behavior | `bashly.adapter` |
| produce shell-wrap handoff for repo close-out | `bashly.closeout` |

## Workflow order

```text
bashly.discovery
→ bashly.edit
→ bashly.validate
→ bashly.generate
→ bashly.closeout
```

Hookrail executable-adapter work:

```text
bashly.discovery
→ bashly.adapter
→ bashly.validate
→ bashly.generate
→ bashly.closeout
```

Skip steps only when the task is already narrower.

## Boundaries

- Edit Bashly config/source, not generated output.
- Inspect generated output as evidence only.
- Do not patch generated shell as the durable fix.
- Do not change Hookrail CUE contracts from this domain.
- Do not stage or commit from this domain.
- Hand Git state and commits to `git-workflow`.

## Validation

Use the smallest relevant validation set.

Default order:

```text
shellharden
shfmt
shellcheck source
bashly generate
```

## Stop

Stop after the selected `bashly-workflow` task report.
