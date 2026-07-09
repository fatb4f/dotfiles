# Snacks Explorer Project Workflow

## Core invariant

```text
WezTerm owns project/session topology.
Neovim owns editor-local file exploration through Snacks explorer.
smart-splits owns Neovim/WezTerm focus and resize mechanics.
```

## Authority matrix

| Surface | Owns | Must not own |
|---|---|---|
| WezTerm project registry | Project identity, roots, cwd, editor env, socket env | Editor buffer state |
| WezTerm sessionizer | Workspace selection and `SwitchToWorkspace` | Neovim project topology |
| WezTerm controller | Launch/focus socket-backed Neovim | File explorer panes or external explorer RPC |
| Neovim Snacks explorer | Editor-local file browsing, reveal, preview, filesystem operations | WezTerm project/session selection |
| smart-splits | Split/pane navigation and resize | Project topology |

## Request flow

| User action | Route | Expected result |
|---|---|---|
| `Alt-s` sessionizer | WezTerm sessionizer | Project workspace selected or spawned |
| Palette: `Launch project IDE` | `events.lua` -> `controller.launch(window)` | Socket-backed Neovim opens for the active project |
| `<leader>e` / `<leader>fe` | `Snacks.explorer({ cwd = project_root })` | Project-root explorer opens in Neovim |
| `<leader>E` / `<leader>fE` | `Snacks.explorer({ cwd = vim.uv.cwd() })` | cwd explorer opens in Neovim |
| `<C-h/j/k/l>` | smart-splits | Move across Neovim splits and WezTerm panes |
| `<A-h/j/k/l>` | smart-splits | Resize active split/pane |

## Validation commands

```bash
stylua --check chezmoi/private_dot_config/nvim/init.lua chezmoi/private_dot_config/nvim/lua/config/*.lua chezmoi/private_dot_config/nvim/lua/plugins/*.lua chezmoi/private_dot_config/nvim/lua/ui/tinty.lua
stylua --check chezmoi/private_dot_config/wezterm/modules/workspaces/controller.lua chezmoi/private_dot_config/wezterm/modules/workspaces/events.lua chezmoi/private_dot_config/wezterm/modules/workspaces/palette.lua
nvim --headless -u chezmoi/private_dot_config/nvim/init.lua --cmd 'set rtp^=chezmoi/private_dot_config/nvim' +qa
```
