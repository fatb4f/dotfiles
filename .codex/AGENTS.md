# AGENTS.md

Dotfiles source router.

## Authority

Use the repository workspace registry:

```text
../workspace.cue
```

Use the dotfiles skill when available:

```text
chezmoi/dot_local/share/codex/skills/dotfiles/SKILL.md
```

This file is a routing overlay for the chezmoi source tree. It is not a CUE authority file.

## Scope

This router covers the dotfiles source tree rooted at:

```text
chezmoi/
```

It owns routing for files under the chezmoi source root, including:

```text
chezmoi-managed source files
chezmoi ignore policy
chezmoi template files
managed configuration domains under private_dot_config
managed local-bin projections under dot_local/bin
```

It does not own sibling workspace domains outside `chezmoi/`, such as:

```text
shell-wrap/
workspace.cue
.tmp/
.git/
```

Use `workspace.cue` to resolve cross-domain ownership.

## Registry-first workflow

1. Load `../workspace.cue` when the task needs workspace routing.
2. Select the smallest matching domain by registered surface.
3. Stay inside the selected domain unless the task explicitly crosses domains.
4. Load only files required by the selected domain and task.
5. Record edited files and validation evidence before close-out.

## Domain routing

| Path pattern | Owner |
|---|---|
| `chezmoi/.chezmoiignore` | `chezmoi` |
| `chezmoi/dot_zprofile` | `zsh` |
| `chezmoi/dot_zshenv` | `zsh` |
| `chezmoi/private_dot_config/zsh/**` | `zsh` |
| `chezmoi/private_dot_config/hypr/**` | `hypr` |
| `chezmoi/private_dot_config/nvim/**` | `nvim` |
| `chezmoi/private_dot_config/wezterm/**` | `wezterm` |
| `chezmoi/private_dot_config/xplr/**` | `xplr` |
| `chezmoi/dot_local/bin/**` | `local-bin` |
| `chezmoi/dot_local/share/codex/skills/**` | `agent-skills` |

When a path matches several domains, choose the most specific path.

## Boundaries

- Do not assume an `AGENTS.cue` file exists.
- Do not create hidden routing policy outside `workspace.cue`.
- Do not scan all managed files by default.
- Do not edit generated, cache, runtime, or ignored state.
- Do not materialize changes to the home directory unless explicitly requested.
- Do not stage or commit from this router.

## Close-out

Report:

```text
selected domain
files loaded
files changed
validation run
validation skipped with reason
handoff target, if any
```

Stop after the selected dotfiles task report.
