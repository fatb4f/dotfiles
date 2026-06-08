-- lua/lang/enable.lua

vim.lsp.enable({
  "lua_ls",
  "cue",
  "bashls",

  -- JS/TS project-scoped through Bun.
  "vtsls",
  "biome",
})
