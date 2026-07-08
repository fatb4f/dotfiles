-- lua/config/pack.lua

vim.pack.add({
	-- Lua config intelligence for Neovim runtime/plugin APIs.
	{ src = "https://github.com/folke/lazydev.nvim" },

	-- Async utility dependency used by CodeCompanion.
	{ src = "https://github.com/nvim-lua/plenary.nvim" },

	-- LuaLS annotations for WezTerm configuration APIs.
	{ src = "https://github.com/DrKJeff16/wezterm-types" },

	-- Parser install/update adapter.
	-- Native vim.treesitter owns runtime behavior;
	-- this only manages parser supply.
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },

	-- Cross-boundary Neovim window and WezTerm pane navigation.
	{ src = "https://github.com/mrjones2014/smart-splits.nvim" },

	-- Agent Client Protocol client for Codex and other coding agents.
	{ src = "https://github.com/olimorris/codecompanion.nvim", version = vim.version.range("^19.0.0") },
})
