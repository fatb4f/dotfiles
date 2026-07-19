# Snacks Explorer Project Workflow

## Core invariant

```text
WezTerm owns project/session topology and terminal pane lifecycle.
Neovim owns editor-local file exploration through Snacks explorer.
WezTerm native actions own terminal pane focus and resize mechanics.
```

## Authority matrix

| Surface | Owns | Must not own |
|---|---|---|
| WezTerm project registry | Project identity, roots, cwd, and editor env | Editor buffer state |
| WezTerm sessionizer | Workspace selection and `SwitchToWorkspace` | Neovim project topology |
| WezTerm native pane actions | Split, close, zoom, select, focus, and resize terminal panes | Launching project applications |
| Neovim Snacks explorer | Editor-local file browsing, reveal, preview, filesystem operations | WezTerm project/session selection |
| Neovim smart-splits | Editor-local split navigation and resize | WezTerm terminal panes or project topology |

## Request flow

| User action | Route | Expected result |
|---|---|---|
| `Alt-s` sessionizer | WezTerm sessionizer | Project workspace selected or spawned |
| `Ctrl+Shift+S` / `Ctrl+Shift+D` | `SplitPane` right / down | A shell pane opens without launching an application |
| `Ctrl+Shift+Z` | `TogglePaneZoomState` | Active pane toggles between zoomed and tiled |
| `Ctrl+Shift+W` | `CloseCurrentPane` | Active pane closes after confirmation |
| `Ctrl+Shift+O` | `PaneSelect` | Pane selection overlay opens with pane IDs |
| `<leader>e` / `<leader>fe` | `Snacks.explorer({ cwd = project_root })` | Project-root explorer opens in Neovim |
| `<leader>E` / `<leader>fE` | `Snacks.explorer({ cwd = vim.uv.cwd() })` | cwd explorer opens in Neovim |
| `Ctrl+Shift+h/j/k/l` | `ActivatePaneDirection` | Focus an adjacent terminal pane |
| `Ctrl+Shift+Alt+h/j/k/l`, then `1…9` | Percentage callback -> `AdjustPaneSize` | Resize by 10%…90% of the active pane width or height |

## Validation commands

```bash
stylua --check chezmoi/private_dot_config/nvim/init.lua chezmoi/private_dot_config/nvim/lua/config/*.lua chezmoi/private_dot_config/nvim/lua/plugins/*.lua chezmoi/private_dot_config/nvim/lua/ui/tinty.lua
stylua --check chezmoi/private_dot_config/wezterm/modules/panes.lua chezmoi/private_dot_config/wezterm/modules/workspaces/*.lua
nvim --headless -u chezmoi/private_dot_config/nvim/init.lua --cmd 'set rtp^=chezmoi/private_dot_config/nvim' +qa
```
