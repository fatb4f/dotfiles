return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			opts.servers = opts.servers or {}
			opts.servers.cue = {
				cmd = { "cue", "lsp", "serve" },
				filetypes = { "cue" },
				root_dir = function(fname)
					return vim.fs.root(fname, { "cue.mod", ".git" }) or vim.uv.cwd()
				end,
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
