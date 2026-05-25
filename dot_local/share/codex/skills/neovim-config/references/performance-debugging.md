# Performance Debugging

Use this reference for startup time, sluggish UI, slow plugin loading, or lazy-loading cleanup.

## Evidence first

Prefer measurement before optimization.

Collect startup timing:

```sh
nvim --startuptime /tmp/nvim-startuptime.log +qa
```

Inside Neovim:

```vim
:Lazy profile
:checkhealth
```

## Common causes

| Cause | Signal |
|---|---|
| top-level `require()` | plugin loads before trigger |
| eager plugin setup | startup time increases |
| expensive filesystem scan | slow init or BufEnter |
| broad autocmd | every buffer triggers heavy logic |
| slow statusline/theme integration | UI delay after startup |
| LSP starts too eagerly | project opens slowly |

## Lazy-loading fixes

Prefer precise triggers:

- `cmd` for command plugins
- `keys` for mapping plugins
- `ft` for language plugins
- `InsertEnter` for completion
- `LspAttach` for LSP UI helpers
- `BufReadPost` for buffer inspection tools

Avoid using `VeryLazy` as a dumping ground when a more precise trigger exists.

## Top-level require anti-pattern

Bad:

```lua
local trouble = require("trouble")

return {
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>xx", function() trouble.toggle("diagnostics") end, desc = "Diagnostics" },
    },
    opts = {},
  },
}
```

Better:

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

## Startup budget heuristic

Treat these as rough triage thresholds, not absolute rules:

- under 50ms: excellent
- 50-100ms: good
- 100-200ms: acceptable depending on setup
- over 200ms: inspect eager plugin loading

## Verification

After a patch, compare:

```sh
nvim --startuptime /tmp/nvim-before.log +qa
nvim --startuptime /tmp/nvim-after.log +qa
```

Then inspect `:Lazy profile` interactively.
