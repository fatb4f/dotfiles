local launchers = require("lang.launchers")

---@type vim.lsp.Config
return {
  cmd = launchers.bunx("@vtsls/language-server", "vtsls", "--stdio"),
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_markers = {
    { "bun.lock", "package.json" },
    { "tsconfig.json", "jsconfig.json" },
    ".git",
  },
  workspace_required = true,
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
    },
  },
}
