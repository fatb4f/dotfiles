-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local borealis_clipboard = vim.api.nvim_create_augroup("borealis_clipboard", { clear = true })
local borealis_shell = vim.api.nvim_create_augroup("borealis_shell", { clear = true })
local borealis_startup = vim.api.nvim_create_augroup("borealis_startup", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = borealis_clipboard,
  pattern = "VeryLazy",
  callback = function()
    require("config.clipboard").setup()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = borealis_shell,
  pattern = { "sh", "bash" },
  callback = function()
    local opts = vim.opt_local
    opts.wrap = false
    opts.linebreak = false
    opts.spell = false
    opts.conceallevel = 0
    opts.expandtab = true
    opts.tabstop = 2
    opts.shiftwidth = 2
    opts.softtabstop = 2
    opts.formatoptions:remove({ "t" })
    opts.commentstring = "# %s"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = borealis_startup,
  pattern = "snacks_dashboard",
  callback = function()
    if vim.fn.argc() ~= 0 then
      return
    end

    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(0) and vim.bo.filetype == "snacks_dashboard" then
        require("snacks").explorer()
      end
    end)
  end,
})
