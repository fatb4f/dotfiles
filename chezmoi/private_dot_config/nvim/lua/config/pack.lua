-- lua/config/pack.lua

vim.pack.add({
  -- Lua config intelligence for Neovim runtime/plugin APIs.
  { src = "https://github.com/folke/lazydev.nvim" },

  -- Parser install/update adapter.
  -- Native vim.treesitter owns runtime behavior;
  -- this only manages parser supply.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },

  -- Optional: keep only if external formatter orchestration beats hand-rolled autocmds.
  { src = "https://github.com/stevearc/conform.nvim" },

  -- Optional: keep only for non-LSP lint producers like shellcheck.
  { src = "https://github.com/mfussenegger/nvim-lint" },
})
