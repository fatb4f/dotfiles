local launchers = require("lang.launchers")

---@type vim.lsp.Config
return {
  cmd = launchers.bunx("@biomejs/biome", "biome", "lsp-proxy"),
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
