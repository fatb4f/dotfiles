---@type vim.lsp.Config
return {
  cmd = { "cue", "lsp", "serve" },
  filetypes = { "cue" },
  root_markers = {
    "cue.mod",
    ".git",
  },
  workspace_required = true,
}
