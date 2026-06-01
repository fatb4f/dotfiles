# AGENTS.md

Chezmoi domain router.

## Authority

Use:

```text
chezmoi-workflow
```

## Scope

This domain owns chezmoi-managed dotfile lifecycle:

```text
source files
target/rendered files
managed path mapping
drift
apply preview
dotfile lifecycle close-out
```

Git state and commits are outside this domain.

Use `git-workflow` for:

```text
git.discovery
git.closeout
staging
commits
final Git status
```

## Task routing

Pick one task. Load the skill procedure from `chezmoi-workflow/SKILL.md`.

| Task pattern                                                   | Skill task                |
| -------------------------------------------------------------- | ------------------------- |
| identify chezmoi state / managed paths / source-target mapping | `chezmoi.discovery`       |
| classify existing source/rendered drift                        | `chezmoi.drift`           |
| edit authoritative chezmoi source files                        | `chezmoi.edit`            |
| inspect source-to-target/rendered relationship                 | `chezmoi.materialization` |
| preview what apply/materialization would change                | `chezmoi.apply-preview`   |
| produce chezmoi status/diff handoff for repo close-out         | `chezmoi.closeout`        |

## Workflow order

```text
chezmoi.discovery
→ chezmoi.drift
→ chezmoi.edit
→ chezmoi.materialization
→ chezmoi.apply-preview
→ chezmoi.closeout
```

Skip steps only when the task is already narrower.

## Limits

* Do not scan all managed files by default.
* Do not inspect Hookrail or shell-wrapper domains unless the task explicitly crosses domains.
* Do not edit rendered target files when a chezmoi source file is authoritative.
* Do not run `chezmoi apply` unless explicitly requested.
* Do not stage or commit from this domain.
* Do not expand into Git close-out; hand off to `git-workflow`.

## Stop

Stop after the selected `chezmoi-workflow` task report.
