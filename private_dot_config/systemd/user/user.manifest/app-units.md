# App launch units

App launch units are started on demand by launch adapters. They should not be enabled directly.

## Units

- `app-nvim@.service`: systemd-owned Neovim app session.

## Current app-nvim contract

```text
nvim desktop entry / launcher
→ nvim-unit-launch
→ systemctl --user start app-nvim@<id>.service
→ nvim-unit-run <id>
→ kitty -e nvim <args>
```

The unit boundary owns the combined Kitty-hosted Neovim session. Bare `nvim` remains a child process of Kitty because Neovim is a TUI.
