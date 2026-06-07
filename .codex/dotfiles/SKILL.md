# Dotfiles Skill

Use this skill for repository-level dotfiles routing, workspace registry work, and cross-domain handoff.

## Contract

The workspace registry is:

```text
workspace.cue
```

The registry is the authority for workspace domains, surfaces, validations, and handoff targets.

`AGENTS.md` files are routing overlays. They may explain procedure, but they must not invent registry authority that is absent from `workspace.cue`.

## Scope

This skill owns:

```text
workspace discovery
workspace.cue registry review
workspace.cue registry edits
path-to-domain routing
cross-domain handoff
repository close-out summary
```

This skill does not own:

```text
chezmoi apply
shell-wrap generation
domain-specific config edits
runtime cache state
git object storage
```

## Required inputs

Before acting, identify:

```text
task intent
candidate paths
selected workspace domain
required router file
required validation evidence
```

Use the smallest matching domain. Prefer exact path surfaces over broad surfaces.

## Tasks

### dotfiles.discovery

Use when the task asks what exists in the dotfiles workspace.

Steps:

1. Inspect repository root files.
2. Inspect durable non-git top-level domains.
3. Ignore `.git/` and runtime/cache paths.
4. Report durable surfaces only.

Output:

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
3. Match requested path or task to a domain.
4. Report the selected domain and why it matched.

Output:

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

Output:

```text
selected domain
handoff router
handoff task
files allowed for next step
```

### dotfiles.edit-registry

Use when adding, removing, or modifying workspace domains.

Steps:

1. Edit only `workspace.cue` unless another file is explicitly part of the registry change.
2. Preserve the schema before editing domain instances.
3. Add new domains with `name`, `kind`, `root`, `surfaces`, and `owns`.
4. Add `router` only when the referenced router file exists or is created in the same change.
5. Add validations only when they are concrete commands or explicit review checks.

Validation:

```text
cue vet workspace.cue
cue eval workspace.cue
```

If CUE is unavailable, report that validation was skipped and provide the reason.

Output:

```text
registry fields changed
domains added
domains modified
validation evidence
```

### dotfiles.closeout

Use at the end of repository-level dotfiles work.

Report:

```text
selected domain
files loaded
files changed
validations run
validations skipped with reason
handoff target, if any
```

## File loading policy

Allowed by default:

```text
workspace.cue
.chezmoiroot
.gitignore
chezmoi/AGENTS.md
shell-wrap/AGENTS.md
```

Load additional files only when they match the selected domain surface in `workspace.cue`.

Denied by default:

```text
.git/**
.tmp/**
cache paths
runtime state paths
auth files
```

## Close-out rule

Stop after the selected dotfiles task report.

Do not stage, commit, apply, regenerate, or reload unless explicitly requested.
