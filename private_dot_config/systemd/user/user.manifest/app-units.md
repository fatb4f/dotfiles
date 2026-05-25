# App launch units

App launch units are started on demand by launch adapters. They should not be enabled directly.

## Units

- `app-nvim@.service`: systemd-owned Neovim app session.

## Current app-nvim contract

```text
nvim desktop entry / launcher
-> nvim-unit-launch
-> systemctl --user start app-nvim@<id>.service
-> nvim-unit-run <id>
-> term-open -e nvim <args>
```

The unit boundary owns the terminal-hosted Neovim session. Bare `nvim`
remains a child process of the configured terminal role because Neovim is a
TUI. `DOTFILES_TERMINAL` currently defaults to WezTerm; Kitty remains available
as a legacy fallback, not as the primary launch authority.
