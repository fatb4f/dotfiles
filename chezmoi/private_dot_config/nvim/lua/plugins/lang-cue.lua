return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			opts.servers = opts.servers or {}
			opts.servers.cue = {
				cmd = { vim.fn.expand("~/.local/share/go/bin/cue"), "lsp", "serve" },
				filetypes = { "cue" },
				root_markers = { "cue.mod", ".git" },
			}
		end,
	},
	{
		"mfussenegger/nvim-lint",
		opts = function(_, opts)
			opts.linters_by_ft = opts.linters_by_ft or {}
			opts.linters_by_ft.cue = { "cue" }
			opts.linters = opts.linters or {}
			opts.linters.cue = {
				cmd = vim.fn.expand("~/.local/share/go/bin/cue"),
			}
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "cue" })
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.cue = {}
		end,
	},
}
