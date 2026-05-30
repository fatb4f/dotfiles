# App launch units

App launch units are started on demand by concrete application entrypoints.
They should not be enabled directly.

## Units

- `app-nvim@.service`: systemd-owned Neovim app session.

## Current app-nvim contract

```text
nvim desktop entry / launcher
-> nvim-unit-launch
-> systemctl --user start app-nvim@<id>.service
-> nvim-unit-run <id>
-> wezterm -e nvim <args>
```

The unit boundary owns the terminal-hosted Neovim session. Bare `nvim`
remains a child process of the configured terminal because Neovim is a TUI.
`TERMINAL` defaults to WezTerm; Kitty remains available as an explicit fallback,
not as the primary launch authority.
