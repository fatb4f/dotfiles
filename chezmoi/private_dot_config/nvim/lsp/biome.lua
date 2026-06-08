---@type vim.lsp.Config
return {
  cmd = { "bun", "run", "lsp:biome" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "css",
    "graphql",
  },
  root_markers = {
    "biome.json",
    "biome.jsonc",
    "package.json",
    "bun.lock",
    ".git",
  },
  workspace_required = true,
}
