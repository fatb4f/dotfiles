# lazy.nvim Plugin Specs

Use this reference for plain `lazy.nvim` plugin files and LazyVim-compatible plugin overlays.

## Minimal plugin spec

```lua
return {
  {
    "author/plugin.nvim",
    event = "BufReadPre",
    opts = {},
  },
}
```

## Preferred lazy triggers

| Trigger | Use for |
|---|---|
| `cmd` | command-driven plugins |
| `keys` | keymap-driven plugins |
| `ft` | language-specific plugins |
| `event = "InsertEnter"` | completion/snippet tools |
| `event = "BufReadPre"` | plugins needed before file read |
| `event = "BufReadPost"` | plugins that inspect loaded buffers |
| `event = "VeryLazy"` | low-priority UI or integration plugins |
| `lazy = true` | dependencies loaded by another plugin |
| `lazy = false` | startup-critical plugins only |

## Good command-driven plugin

```lua
return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
    },
    opts = {},
  },
}
```

## Good filetype plugin

```lua
return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
}
```

## Config versus opts

Prefer `opts` when the plugin supports `setup(opts)`.

```lua
return {
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
    },
  },
}
```

Use `config` only when setup logic is conditional or requires custom code:

```lua
return {
  {
    "author/plugin.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("plugin").setup(opts)
      vim.api.nvim_create_user_command("PluginExtra", function()
        require("plugin").extra()
      end, {})
    end,
  },
}
```

## Duplicate spec warning

Before adding a plugin, search for existing specs:

```sh
rg 'plugin-name|author/plugin.nvim' lua init.lua lazy-lock.json
```

Prefer modifying the existing spec.

## Startup anti-patterns

Avoid:

```lua
local plugin = require("plugin")
plugin.setup({})
```

at module top level for a plugin that should be lazy-loaded.

Avoid broad `VeryLazy` when `cmd`, `keys`, or `ft` is more precise.
