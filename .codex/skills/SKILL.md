---
name: dotfiles skill
description: meta-skill
---
Use this skill for repository-level dotfiles routing, workspace registry review,
workspace registry edits, and cross-domain handoff.

## Authority

```text
workspace.cue is the registry authority.
.codex/workflow.cue is the validation workflow authority.
.codex/hooks.json calls the validate command after tool use.
.github/workflows/cue.yml calls the same validate command in CI.
```

`workspace.cue` records workspace domains, domain roots, surfaces, ownership,
denied concerns, validations, handoff routers, and registered skills.

`.codex/workflow.cue` defines the hook payload shapes and base workspace CUE
checks. The hook command passes the Codex payload into CUE's `validate` command.
The CUE tool entrypoint lives in `.codex/workflow_tool.cue`, as required by
CUE's `_tool.cue` command discovery convention.

Skills and `AGENTS.md` files are procedural overlays. They may route, explain,
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

Delegate domain-specific work to the smallest matching global skill:

| Concern | Delegate to |
|---|---|
| Local search, discovery, path narrowing | `file-search` |
| JSON, YAML, TOML, XML, CSV edits | `data-tools` |
| Missing CLI tools or environment audit | `cli-tools` |
| Git staging, commit, diff, and Git closeout | `git-workflow` |
| Chezmoi source/rendered lifecycle | `chezmoi-workflow` |
| Bashly and shell-wrapper lifecycle | `bashly-workflow` |
| Neovim Lua configuration | `neovim` |

## Routing

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

Use the smallest matching domain. Prefer exact path surfaces over broad
surfaces.

## Tasks

### dotfiles.discovery

Inspect durable repository-level files and durable non-git top-level domains.
Ignore `.git/`, runtime state, cache state, and auth state.

Report:

```text
durable roots
router files present
registry file present or absent
candidate domain owners
```

### dotfiles.registry

Load `workspace.cue`, identify `workspace.registries.domains`, and match the
requested path or task to the smallest domain.

Report:

```text
selected domain
matched surface
router
owned concerns
denied concerns
validations
```

### dotfiles.route

Resolve paths against `workspace.cue`, pick the most specific domain, and enter
the domain router if present. Do not load unrelated domain files.

Report:

```text
selected domain
handoff router
handoff task
files allowed for next step
```

### dotfiles.edit-registry

Edit only `workspace.cue` unless another file is explicitly part of the
requested registry change. Preserve existing naming, field order, and schema
structure. Add router paths only when the referenced router exists or is created
in the same change.

Validate with the shared workflow:

```text
cue cmd validate ./.codex
```

## Boundary

This skill routes and narrows work.

CUE validates the workspace workflow.

Hooks provide local post-tool feedback.

CI promotes the same validation path.
