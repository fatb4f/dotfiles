---

name: chezmoi-workflow
description: "Thin task index for chezmoi source/rendered discovery, drift review, source edits, materialization preview, bounded apply, apply preview, and close-out."
when_to_use: Use when AGENTS.md or the user references chezmoi.discovery, chezmoi.drift, chezmoi.edit, chezmoi.materialization, chezmoi.apply-preview, chezmoi.apply, or chezmoi.closeout.
license: "Repo-local"
compatibility: "Requires chezmoi CLI. Git commits must be delegated to git-workflow."

---

# Chezmoi Workflow Skill

This skill is a thin task index for chezmoi-managed dotfile lifecycle work.

Use it to select the correct chezmoi task procedure.

Do not use this skill for Git staging or commits. Use `git-workflow` for Git state.

## Core rules

1. Treat chezmoi source and target/rendered state as distinct surfaces.
2. Prefer discovery and drift classification before edits.
3. Edit source files, not rendered target files, unless the user explicitly requests target-side repair.
4. Do not run `chezmoi apply` outside the `chezmoi.apply` task or an explicit user request.
5. Do not assume rendered drift is safe to apply.
6. Keep discovery bounded to the requested dotfile pattern.
7. Delegate Git close-out to `git-workflow`.

## Workflow order

```text id="irvai6"
chezmoi.discovery
→ chezmoi.drift
→ chezmoi.edit
→ chezmoi.materialization
→ chezmoi.apply-preview
→ chezmoi.apply
→ chezmoi.closeout
```

## Tasks

| Order | Task                      | Use for                                                          | Procedure                             |
| ---: | --- | --- | --- |
| 1 | `chezmoi.discovery` | Identify chezmoi state, managed paths, and source/target mapping | `references/tasks/discovery.md` |
| 2 | `chezmoi.drift` | Classify existing source/rendered drift before change | `references/tasks/drift.md` |
| 3 | `chezmoi.edit` | Edit authoritative chezmoi source files | `references/tasks/edit.md` |
| 4 | `chezmoi.materialization` | Inspect source-to-target/rendered relationship | `references/tasks/materialization.md` |
| 5 | `chezmoi.apply-preview` | Preview what apply/materialization would change | `references/tasks/apply-preview.md` |
| 6 | `chezmoi.apply` | Materialize bounded source changes to target files | `references/tasks/apply.md` |
| 7 | `chezmoi.closeout` | Produce chezmoi status/diff handoff for repo close-out | `references/tasks/closeout.md` |

## Cross-skill boundary

Use this skill for chezmoi state:

```text id="62xr3a"
source files
target/rendered files
managed path mapping
drift
apply preview
dotfile lifecycle close-out
```

Use `git-workflow` for Git state:

```text id="z3zo6m"
git.discovery
git.closeout
staging
commits
final Git status
```

During repo close-out:

```text id="4q5j6b"
1. Run git.discovery.
2. Run chezmoi.closeout.
3. Run git.closeout only when commit-before-summary is explicitly requested.
```

## Skill invariant

```text id="u8q0o9"
AGENTS.md selects a chezmoi task.
chezmoi-workflow/SKILL.md maps the task to a task reference.
references/tasks/*.md defines commands, output, and stop conditions.
chezmoi CLI observes or previews source/rendered state.
git-workflow owns Git close-out.
```
