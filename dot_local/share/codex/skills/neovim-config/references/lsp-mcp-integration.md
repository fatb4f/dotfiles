# LSP MCP Integration

Use this reference when an MCP server provides live Neovim LSP diagnostics or buffer context.

## Role

`nvim-lsp-mcp`-style tools are live-session evidence sources. They are not full config validators.

They are useful after edits because they query the active Neovim session rather than a synthetic shell command.

## Good use cases

- read diagnostics from currently loaded buffers
- confirm whether an edit introduced LSP or lint errors
- inspect active LSP client state
- retrieve hover information for the current code context
- retrieve document symbols from an open buffer
- compare live editor diagnostics with shell checks

## Bad use cases

Do not rely on LSP MCP for:

- startup failures
- broken plugin specs
- LazyVim overlay errors before UI loads
- full workspace validation
- unopened files
- performance profiling
- missing external binaries that prevent the server from starting

## Preferred loop

1. Codex edits a file.
2. Query live diagnostics through MCP if available.
3. Patch diagnostics directly caused by the edit.
4. Run headless Neovim checks if config files changed.
5. Review diff with Git tooling.

## Fallback loop

When MCP is unavailable:

```sh
nvim --headless "+checkhealth" "+qa"
nvim --startuptime /tmp/nvim-startuptime.log +qa
```

For project code diagnostics, use project-native tooling when available:

```sh
npm test
pytest
cargo check
go test ./...
```

## Validity constraints

Live LSP MCP evidence is valid only when:

- Neovim is running
- the workspace path matches the target repo
- the target file is loaded or opened
- the relevant LSP server has attached
- diagnostics have had time to refresh

If these constraints are not met, treat missing diagnostics as inconclusive.
