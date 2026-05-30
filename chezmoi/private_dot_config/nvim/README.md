# Neovim Terminal Contract

Neovim is the standard editor (`EDITOR=nvim`, `VISUAL=nvim`). Shell entrypoints
should use those variables. Compositor entrypoints should launch a concrete
terminal/editor command, such as `wezterm -e nvim`.

When Neovim runs inside WezTerm, `lua/plugins/smart-splits.lua` emits the pane
user var `IS_NVIM=true`. WezTerm reads that value in
`wezterm/modules/smart_splits.lua` and routes split keys across the correct
boundary.

Key contract:

- `Ctrl+h/j/k/l`: move left/down/up/right through Neovim splits, or WezTerm
  panes when the active pane is not Neovim.
- `Alt+h/j/k/l`: resize left/down/up/right by 3 cells through Neovim splits,
  or WezTerm panes when the active pane is not Neovim.

Kitty-specific helpers remain legacy/fallback integrations. WezTerm owns
terminal-local panes, tabs, workspaces, layouts, and pane lifecycle.

## WezTerm pane

Neovim owns the pane cache and exposes the v0 pane commands:

- `:WeztermPaneToggle`: focus the cached pane, or split a new pane.
- `:WeztermPaneFocus`: focus the cached pane, or create one if the
  cache is empty or stale.
- `:WeztermPaneRun <cmd>`: ensure the pane exists, then send `<cmd>`
  followed by a newline.
- `:WeztermPaneKill`: kill the cached pane and clear the cache.

Neovim manipulates the pane through `wezterm cli`. New panes inherit Neovim's
current working directory.
