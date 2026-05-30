-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

require("config.wezterm-pane").setup()

vim.keymap.set("n", "<leader>ot", function()
  require("config.wezterm-pane").toggle()
end, { desc = "Toggle WezTerm pane" })

vim.keymap.set("n", "<leader>ok", function()
  require("config.wezterm-pane").kill()
end, { desc = "Kill WezTerm pane" })
