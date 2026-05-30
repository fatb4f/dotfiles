# neovim-config skill

Standard Codex skill for Neovim, LazyVim, lazy.nvim, LSP, diagnostics, formatters, plugin specs, startup performance, and optional live LSP MCP evidence.

## Layout

```text
neovim-config/
├── SKILL.md
├── references/
├── scripts/
└── evals/
```

## Install

Copy this directory into your Codex skills tree:

```sh
cp -a neovim-config "$CODEX_HOME/skills/neovim-config"
```

## Scripts

```sh
scripts/executable_check_nvim_config.sh
scripts/executable_collect_nvim_evidence.sh ./nvim-evidence
scripts/executable_check_lua_syntax.sh
```

The scripts are evidence helpers. They do not replace repo-specific tests.
