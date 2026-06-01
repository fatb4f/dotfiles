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

