# Neovim Terminal Contract

Neovim is the configured editor role (`DOTFILES_EDITOR=nvim`) and IDE role
fallback (`DOTFILES_IDE=${DOTFILES_EDITOR}`). Shell and compositor entrypoints
should launch it through `editor-open` or `ide-role` instead of hardcoding a
terminal/editor pair.

When Neovim runs inside WezTerm, `lua/plugins/smart-splits.lua` emits the pane
user var `IS_NVIM=true`. WezTerm reads that value in
`wezterm/modules/smart_splits.lua` and routes split keys across the correct
boundary.

Key contract:

- `Ctrl+h/j/k/l`: move left/down/up/right through Neovim splits, or WezTerm
  panes when the active pane is not Neovim.
- `Alt+h/j/k/l`: resize left/down/up/right by 3 cells through Neovim splits,
  or WezTerm panes when the active pane is not Neovim.

Kitty-specific helpers remain legacy/fallback integrations while the terminal
role migration is in progress.
