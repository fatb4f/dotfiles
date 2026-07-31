local uv = require("util.python_uv")

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				ruff = {
					cmd = uv.start_lsp("ruff"),
					filetypes = { "python" },
					root_markers = { "pyproject.toml", "uv.lock", "ruff.toml", ".ruff.toml", ".git" },
					workspace_required = true,
				},
				ty = {
					cmd = uv.start_lsp("ty"),
					filetypes = { "python" },
					root_markers = {
						"ty.toml",
						"pyproject.toml",
						"uv.lock",
						"setup.py",
						"setup.cfg",
						"requirements.txt",
						".git",
					},
					workspace_required = true,
				},
			},
		},
	},
	{
		"nvim-neotest/neotest",
		dependencies = { "nvim-neotest/neotest-python" },
		opts = function(_, opts)
			opts.adapters = opts.adapters or {}
			table.insert(
				opts.adapters,
				require("neotest-python")({
					runner = "pytest",
					python = function(root)
						return uv.command(root, "python")
					end,
				})
			)
		end,
	},
}
