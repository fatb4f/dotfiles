-- lua/lang/diagnostics.lua

vim.diagnostic.config({
  virtual_text = {
    source = "if_many",
    spacing = 2,
  },
  severity_sort = true,
  float = {
    source = true,
    border = "rounded",
  },
  signs = true,
  underline = true,
})
