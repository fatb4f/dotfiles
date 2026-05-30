# LSP, Formatting, and Diagnostics

Use this reference when configuring language servers, diagnostics, formatters, and linters.

## Separate responsibilities

| Concern | Typical owner |
|---|---|
| LSP protocol | Neovim built-in LSP |
| LSP server config | `nvim-lspconfig` or `vim.lsp.config()` |
| Tool installation | Mason or system package manager |
| Formatting | `conform.nvim` |
| Linting | `nvim-lint` |
| Diagnostic display | `vim.diagnostic.config` |

## Language support checklist

For each language, identify:

- external binary name
- Mason package name
- LSP server key
- formatter
- linter
- filetypes
- root detection
- whether formatting comes from LSP or `conform.nvim`

## LazyVim LSP server overlay

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
    end,
  },
}
```

## Plain Neovim 0.11+ style

Use this only when the repository is already using the modern built-in LSP config style:

```lua
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})
vim.lsp.enable("lua_ls")
```

## CUE LSP example

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.cue_ls = {
        cmd = { "cue", "lsp", "serve" },
        filetypes = { "cue" },
        root_markers = { "cue.mod", ".git" },
      }
    end,
  },
}
```

If `root_markers` is unsupported by the local config layer, adapt to that repo's existing `root_dir` style.

## Conform formatting overlay

```lua
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.lua = { "stylua" }
      opts.formatters_by_ft.sh = { "shfmt" }
      opts.formatters_by_ft.python = { "ruff_format" }
    end,
  },
}
```

## Diagnostic display

```lua
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    prefix = "●",
  },
  severity_sort = true,
  signs = true,
  underline = true,
  update_in_insert = false,
})
```

## Debug commands

```vim
:LspInfo
:Mason
:checkhealth vim.lsp
:ConformInfo
:messages
```

## Common failure classifications

| Symptom | Likely cause |
|---|---|
| no LSP attaches | wrong filetype, root detection, missing binary |
| diagnostics but no formatting | formatter not installed or not configured |
| formatting conflicts | multiple formatters enabled |
| server starts in wrong root | root detection issue |
| hover/definition unavailable | server attached without capability or file not in project root |
