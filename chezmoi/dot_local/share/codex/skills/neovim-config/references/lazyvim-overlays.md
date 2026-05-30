# LazyVim Overlays

Use this reference when the repository uses LazyVim.

## Detection

LazyVim is likely present when any of these are true:

- `lazy-lock.json` contains `LazyVim`
- plugin specs reference `LazyVim/LazyVim`
- files follow LazyVim conventions under `lua/plugins/`
- `lua/config/lazy.lua` imports LazyVim extras or plugin modules

## Rule

Prefer extending LazyVim defaults through plugin overlays instead of replacing full setup blocks.

## Safe overlay pattern

```lua
return {
  {
    "plugin/name.nvim",
    opts = function(_, opts)
      opts.some_table = opts.some_table or {}
      opts.some_table.enabled = true
    end,
  },
}
```

## LSP overlay pattern

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.bashls = vim.tbl_deep_extend("force", opts.servers.bashls or {}, {
        filetypes = { "bash", "sh" },
      })
    end,
  },
}
```

## Mason overlay pattern

If the config uses LazyVim's Mason integration directly:

```lua
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "shfmt",
        "shellcheck",
      })
    end,
  },
}
```

If the repo uses `mason-tool-installer.nvim`, extend that plugin instead.

## Avoid

```lua
require("plugin").setup({ ... })
```

at top level in a LazyVim config.

Avoid replacing an entire LazyVim-managed setup unless the user explicitly wants to own that plugin.

## Colorscheme notes

Only one loader should own the active colorscheme.

For `tinted-nvim` with LazyVim:

```lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("tinted-nvim").load()
      end,
    },
  },
}
```

For lualine theme safety:

```lua
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "auto"
    end,
  },
}
```
