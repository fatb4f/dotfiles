# AGENTS.md

Chezmoi domain router.

## Cue-Flow Loop Contract

The intended cue-flow loop is root-contract driven:

1. Repository-local `AGENTS.cue` is the node contract when present.
2. `AGENTS.md` states protocol and routing only; use it as natural-language overlay, not as the authority over CUE.
3. File loads require CUE authorization evidence: selected node, selected pattern, explicit index, or root-declared fallback surface.
4. Adapters and MCP tools may emit evidence, but they must not create hidden authorization policy.
5. Record loaded files, denied loads, required MCP/tool use, and validation evidence before close-out.

## Authority

Use:

```text
chezmoi/dot_local/share/codex/skills/chezmoi-workflow/SKILL.md
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
| materialize bounded source changes to target files             | `chezmoi.apply`           |
| produce chezmoi status/diff handoff for repo close-out         | `chezmoi.closeout`        |

## Workflow order

```text
chezmoi.discovery
→ chezmoi.drift
→ chezmoi.edit
→ chezmoi.materialization
→ chezmoi.apply-preview
→ chezmoi.apply
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

## Apply rule

For `chezmoi.apply`, require an explicit target path.

If the user says "apply it" after a previous edit, apply only the paths from the immediately preceding chezmoi task.

Do not rediscover broadly.
Do not explain options.
Do not force.

## Stop

Stop after the selected `chezmoi-workflow` task report.
