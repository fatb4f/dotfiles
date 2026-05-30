# Troubleshooting Reference

## Fast triage

| Problem | First check |
|---|---|
| config does not start | `nvim --headless "+qa"` |
| health issue | `nvim --headless "+checkhealth" "+qa"` |
| plugin issue | `:Lazy`, `:Lazy log` |
| startup slow | `:Lazy profile`, `--startuptime` |
| LSP not attaching | `:LspInfo`, filetype, root detection |
| formatter not working | `:ConformInfo` |
| keymap not working | `:verbose map <lhs>` |
| diagnostics mismatch | active buffer diagnostics / LSP MCP if available |

## Missing external tools

Check binaries:

```sh
command -v nvim
command -v lua
command -v stylua
command -v shfmt
command -v shellcheck
command -v rg
command -v fd
```

Check Mason-managed tools inside Neovim:

```vim
:Mason
```

## Lazy.nvim sync

When plugin installation state may be stale:

```sh
nvim --headless "+Lazy! sync" "+qa"
```

Use this carefully. It can modify plugin installation state.

## Runtime path inspection

Inside Neovim:

```vim
:set runtimepath?
:echo stdpath('config')
:echo stdpath('data')
:echo stdpath('state')
```

## Duplicate plugin specs

Search:

```sh
rg 'plugin-name|author/plugin.nvim' lua init.lua lazy-lock.json
```

## Invalid Lua syntax

For a single file:

```sh
luac -p path/to/file.lua
```

If `luac` is not available, use Neovim headless load checks instead.

## Rollback discipline

For risky plugin changes:

1. inspect `git diff`
2. keep patch small
3. verify headless start
4. verify interactive behavior
5. rollback the touched file if the problem persists
