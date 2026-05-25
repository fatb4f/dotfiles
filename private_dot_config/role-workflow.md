# Desktop Role Workflow

The desktop/dev launch path is role-oriented:

```text
environment.d role variables
-> shell environment
-> launch adapters in ~/.local/bin
-> WezTerm terminal role
-> Neovim editor role
-> Hyprland binds
```

## Role Authority

`environment.d/00_init.conf` defines the dotfiles role authority:

- `DOTFILES_TERMINAL=wezterm`
- `DOTFILES_TERMINAL_SHELL=zsh`
- `DOTFILES_EDITOR=nvim`
- `DOTFILES_IDE=${DOTFILES_EDITOR}`

Compatibility variables are projections from those values:

- `TERMINAL=${DOTFILES_TERMINAL}`
- `EDITOR=${DOTFILES_EDITOR}`
- `VISUAL=${DOTFILES_EDITOR}`

## Launch Adapters

Adapters live in `~/.local/bin`:

- `term-open`: launches the configured terminal role.
- `editor-open`: launches the configured editor role.
- `ide-role`: launches the configured IDE/editor role for supported editor
  roles.

Adapters read `DOTFILES_*` role variables and fail with actionable errors when
the configured binary is missing.

## Terminal Stance

WezTerm is the primary terminal role. Its shell program is selected by
`wezterm/modules/shell.lua` in this order:

1. `DOTFILES_TERMINAL_SHELL`
2. `SHELL`
3. `zsh`

Kitty remains installed and callable as a fallback during migration. Hyprland
keeps `SUPER+Shift+Return` as an explicit Kitty fallback, while `SUPER+Return`
uses `term-open`.

## WezTerm and Neovim Splits

Neovim marks the active WezTerm pane with `IS_NVIM=true` while it owns the pane.
WezTerm reads `pane:get_user_vars().IS_NVIM` before handling split keys.

Key contract:

- `Ctrl+h/j/k/l`: move left/down/up/right.
- `Alt+h/j/k/l`: resize left/down/up/right by 3 cells.

When `IS_NVIM=true`, WezTerm forwards those keys into Neovim. Otherwise,
WezTerm moves or resizes terminal panes directly.

## Deferred Work

The shared project/workspace registry is not implemented yet. Debug, repl, log,
and richer project workflow roles are also deferred. Current docs should not
present those workflows as complete until the registry and role handlers exist.
