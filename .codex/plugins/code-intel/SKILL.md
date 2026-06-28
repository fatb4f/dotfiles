---
name: dotfiles-code-intel
description: Local generated code-intelligence bundle for dotfiles Lua, CUE, MCP declarations, and WezTerm/Neovim type overlays.
---

# Dotfiles Code Intel

This plugin is a generated, read-only code-intelligence bundle for dotfiles work. It provides local evidence surfaces for Lua-first editing, CUE contracts, MCP provider declarations, and type overlays.

## Contract boundary

- Treat every file under this plugin as generated evidence unless a CUE contract inside `contracts/code-intel/` says otherwise.
- Do not treat MCP output, LSP diagnostics, generated type stubs, or generated workflow JSON as source authority.
- Do not import or depend on the agent-context-resolver bundle.
- Do not reach outside the materialized plugin root for bundle-local authority.

## Lua-first workflow

1. Load `generated/workflows/lua-first/workflow.json`.
2. Resolve entrypoints from `generated/workflows/lua-first/entrypoints.json`.
3. Route Lua files with `generated/lsp/provider-routing.json`.
4. Attach overlays from `generated/types/nvim/vim.lua` and `generated/types/wezterm/*.lua` as read-only libraries.
5. Project diagnostics with `generated/workflows/lua-first/diagnostic-map.json`.
6. Use diagnostics as evidence only; patch authority stays with the target repository source.

## CUE workflow

Use `generated/lsp/cue-lsp.json` for editor/server configuration and `contracts/code-intel/checks.cue` for local bundle boundary checks.

## Validation from package root

```sh
cue vet ./contracts/code-intel
cue export ./contracts/code-intel -e codeIntelLuaFirstWorkflow
cue export ./contracts/code-intel -e codeIntelBoundaryReport
```
