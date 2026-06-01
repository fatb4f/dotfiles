# AGENTS.md

## Purpose

This file is the root routing and scope-control contract for this repository.

Use it to:

* classify the task by domain
* load exactly one starting domain authority
* avoid broad repo scans
* run repo-level Git and chezmoi close-out when requested

Do not use this file as a general repo explanation or policy dump.

## Repo map

```text
dotfiles repo
├── chezmoi/                   # source dotfiles and deployed runtime material
│   └── dot_local/share/codex/tools/hookrail/
├── cue.mods/hookrail/         # CUE contracts, feed shape, projection, closeout
├── shell-wrap/src/hookrail/    # Bashly and shell-adapter implementation
└── authority/                 # reserved future typed surface
```

## Domain authorities

A domain authority is the `AGENTS.md` file at the root of the selected task
domain when that file exists.

Do not recursively discover `AGENTS.md` files.

Choose one starting authority by task pattern.

| Task pattern | Starting authority |
| --- | --- |
| chezmoi dotfile lifecycle work | `chezmoi/AGENTS.md` when present; otherwise the nearest file in the touched `chezmoi/` subtree |
| Hookrail contract, feed, projection, manifest, or closeout work | `cue.mods/AGENTS.md` when present; otherwise `cue.mods/hookrail/projection.cue` and the other touched contract files |
| Bashly, shell-wrapper, command-dispatch, or executable adapter work | `shell-wrap/AGENTS.md` when present; otherwise `shell-wrap/src/hookrail/src/bashly.yml` and the touched command or library file |
| repo-level Git and chezmoi close-out | this root `AGENTS.md` |

## Routing rules

### chezmoi dotfile lifecycle

Use `chezmoi/AGENTS.md` when it exists and the task involves:

* chezmoi-managed dotfiles
* source/rendered lifecycle
* `chezmoi status`, `chezmoi diff`, or drift review
* dotfile materialization
* dotfile close-out

If `chezmoi/AGENTS.md` does not exist yet, start with the nearest file in the
touched `chezmoi/` subtree.

Do not inspect Hookrail or shell-wrapper domains unless the selected authority
explicitly identifies a cross-domain task.

### Hookrail contract and projection

Use `cue.mods/AGENTS.md` when it exists and the task involves:

* Hookrail contracts
* CUE modules
* feed shape
* projection semantics
* generated hook inputs or outputs
* manifest or closeout semantics

If `cue.mods/AGENTS.md` does not exist yet, start with
`cue.mods/hookrail/projection.cue`.

`cue.mods/hookrail/` is part of the repo's Codex runtime. It is not a passive
dotfiles payload.

### Bashly and shell-wrapper

Use `shell-wrap/AGENTS.md` when it exists and the task involves:

* Bashly command shape
* shell wrapper mechanics
* command dispatch
* generated shell adapters
* executable Hookrail adapter behavior

If `shell-wrap/AGENTS.md` does not exist yet, start with
`shell-wrap/src/hookrail/src/bashly.yml`.

`shell-wrap/src/hookrail/` is part of the repo's Codex runtime. It is the
executable shell-adapter side of Hookrail.

### Repo-level close-out

Use this root file when the task is to summarize or close out repository state.

Close-out means status inspection, staging only task-scoped files, diff
verification, targeted validation, commit, and final reporting.

Do not stage, commit, apply, repair, regenerate, or redesign unless the task
explicitly requests repo close-out or implementation.

## Discovery limits

Default behavior:

1. Classify the task pattern.
2. Select one starting authority.
3. Read only that authority and the files it names.
4. Prefer exact paths from the user request.
5. Prefer targeted `rg`, `fd`, `git`, and `chezmoi` queries over broad
   inspection.
6. Stop after the bounded requested output is produced.

Do not:

* scan the whole repo by default
* recursively read every `AGENTS.md`
* inspect unrelated domains
* expand `authority/` unless the task explicitly targets authority-graph work
* compare against legacy frame systems
* resume or reconstruct large prior context unless explicitly required

## Reserved authority surface

`authority/` is a reserved future typed authority surface.

During the interim context-control phase, it is inert unless the task
explicitly targets authority graph work.

Allowed root-level treatment:

* mention that `authority/` is reserved
* inspect it only when directly requested
* avoid expanding it into a second policy system

## Repo close-out procedure

Use this procedure for repo-level close-out, handoff, or status summarization.

### 1. Check Git state

```sh
git status --short
git diff --stat
git diff --name-only
```

When useful, also inspect staged state:

```sh
git diff --cached --stat
git diff --cached --name-only
```

### 2. Check chezmoi state

```sh
chezmoi status
chezmoi diff --stat
```

Do not run `chezmoi apply` unless explicitly requested.

### 3. Validate and close out

Use the repo's Git workflow for staging, diff verification, validation, and
commit. Stage only intentional paths, verify the staged diff, run the smallest
useful validation, then commit with a Conventional Commit message.

### 4. Report

Report:

* selected task domain
* files changed
* generated/rendered drift, if any
* commands run
* unknown or unsafe state
* commit SHA, when a commit is made
* final working tree state

## Root invariant

```text
root = map + router + close-out
nested AGENTS.md = local task procedure
authority/ = future typed target
```
