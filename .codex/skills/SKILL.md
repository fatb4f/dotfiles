```
name: dotfiles skill
description: meta-skill
```
Use this skill for repository-level dotfiles routing, workspace registry review,
workspace registry edits, and cross-domain handoff.

## Authority

The durable workspace registry is:

```text
workspace.cue
```

The Codex hook, workflow, and output policy is:

```text
.codex/workflow.cue
```

`workspace.cue` is the authority for:

```text
workspace domains
domain roots
domain surfaces
domain ownership
denied concerns
validations
handoff routers
registered skills
```

`.codex/workflow.cue` is the authority for:

```text
Codex hook validation
workflow checks
forbidden command checks
closeout schema
closeout field order
validation reporting shape
```

`AGENTS.md` files and skills are procedural overlays. They may route, explain,
or constrain execution, but they must not invent authority absent from
`workspace.cue` or `.codex/workflow.cue`.

## Scope

Use this skill for:

```text
workspace discovery
workspace.cue registry review
workspace.cue registry edits
path-to-domain routing
cross-domain handoff
```

Do not use this skill to define:

```text
closeout format
forbidden commands
hook behavior
CI behavior
validation policy
chezmoi apply behavior
git staging or commits
domain-specific implementation procedures
```

Those concerns are delegated to CUE policy, hooks, CI, or the matching global
skill.

## Global skill delegation

Use the installed global skills as task adapters. Do not duplicate their
procedure here.

| Concern | Delegate to |
|---|---|
| Local search, discovery, path narrowing | `file-search` |
| JSON, YAML, TOML, XML, CSV edits | `data-tools` |
| Missing CLI tools or environment audit | `cli-tools` |
| Git staging, commit, diff, and Git closeout | `git-workflow` |
| Chezmoi source/rendered lifecycle | `chezmoi-workflow` |
| Bashly and shell-wrapper lifecycle | `bashly-workflow` |
| Neovim Lua configuration | `neovim` |

Use the smallest matching skill. Do not load unrelated global skills.

## Required routing inputs

Before acting, identify:

```text
task intent
candidate paths
selected workspace domain
matched workspace surface
required router file
required validation evidence
handoff target, if any
```

Use the smallest matching domain.

Prefer exact path surfaces over broad surfaces.

## Tasks

### dotfiles.discovery

Use when the task asks what exists in the dotfiles workspace.

Steps:

1. Inspect durable repository-level files.
2. Inspect durable non-git top-level domains.
3. Ignore `.git/`, runtime state, cache state, and auth state.
4. Report durable surfaces only.

Output facts:

```text
durable roots
router files present
registry file present or absent
candidate domain owners
```

### dotfiles.registry

Use when reading or checking `workspace.cue`.

Steps:

1. Load `workspace.cue`.
2. Identify `workspace.registries.domains`.
3. Match the requested path or task to a domain.
4. Report the selected domain and why it matched.

Output facts:

```text
selected domain
matched surface
router
owned concerns
denied concerns
validations
```

### dotfiles.route

Use when a task crosses several possible domains.

Steps:

1. Resolve paths against `workspace.cue`.
2. Pick the most specific domain.
3. Enter the domain router if present.
4. Do not load unrelated domain files.
5. Stop after handoff unless the user explicitly asks for execution.

Output facts:

```text
selected domain
handoff router
handoff task
files allowed for next step
```

### dotfiles.edit-registry

Use when adding, removing, or modifying workspace domains.

Steps:

1. Edit only `workspace.cue` unless another file is explicitly part of the
   requested registry change.
2. Preserve existing naming, field order, and schema structure.
3. Add new domains with concrete `name`, `kind`, `root`, `surfaces`, and
   `owns` fields.
4. Add `router` only when the referenced router file exists or is created in
   the same change.
5. Add validations only when they are concrete commands or explicit review
   checks.
6. Do not add task names to a skill registry unless a matching procedure exists
   in the relevant `SKILL.md` or the task is explicitly represented as CUE
   policy.

Validation:

```text
cue vet workspace.cue
cue eval workspace.cue
cue vet .codex/workflow.cue
cue eval .codex/workflow.cue
```

Output facts:

```text
registry fields changed
domains added
domains modified
validation evidence
```

## Closeout

Closeout shape is governed by `.codex/workflow.cue`.

Use:

```text
#Closeout
policy.output.closeout
```

At completion, report the closeout fields required by the active CUE output
policy. Do not invent or duplicate closeout structure in this skill.

If a required validation was not run, report it as skipped with a reason rather
than omitting it.

## Boundary rule

This skill routes and narrows work.

CUE constrains workflow and output.

Hooks enforce local agent feedback.

CI promotes repository state.
