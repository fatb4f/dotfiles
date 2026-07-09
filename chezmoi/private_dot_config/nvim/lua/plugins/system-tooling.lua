return {
	{
		"mason-org/mason.nvim",
		enabled = false,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		enabled = false,
	},
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			opts.servers = opts.servers or {}
			opts.servers.bashls = vim.tbl_deep_extend("force", opts.servers.bashls or {}, {
				cmd = { "bunx", "--bun", "--no-install", "bash-language-server", "start" },
				filetypes = { "sh", "bash", "zsh" },
				mason = false,
				root_dir = function(fname)
					return vim.fs.root(fname, { ".bashly.yml", ".bashly.yaml", ".git" }) or vim.uv.cwd()
				end,
			})

			for _, server in ipairs({ "gopls", "cue", "bashls" }) do
				opts.servers[server] = vim.tbl_deep_extend("force", opts.servers[server] or {}, {
					mason = false,
				})
			end
		end,
	},
}
