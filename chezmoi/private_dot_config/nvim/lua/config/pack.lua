-- lua/config/pack.lua

vim.pack.add({
  -- Lua config intelligence for Neovim runtime/plugin APIs.
  { src = "https://github.com/folke/lazydev.nvim" },

  -- Parser install/update adapter.
  -- Native vim.treesitter owns runtime behavior;
  -- this only manages parser supply.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },

  -- Cross-boundary Neovim window and WezTerm pane navigation.
  { src = "https://github.com/mrjones2014/smart-splits.nvim" },
})
