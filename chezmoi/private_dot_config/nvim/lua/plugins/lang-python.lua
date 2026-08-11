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
		"benomahony/uv.nvim",
		ft = { "python" },
		dependencies = { "folke/snacks.nvim" },
		opts = {
			auto_activate_venv = true,
			picker_integration = true,
			keymaps = false,
			execution = {
				run_command = "uv run --frozen --no-sync python",
				notify_output = true,
			},
		},
		config = function(_, opts)
			require("uv").setup(opts)
			require("util.python_learning").setup()
		end,
	},
}
