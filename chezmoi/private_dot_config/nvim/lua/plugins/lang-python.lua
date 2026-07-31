local root_markers = { "pyproject.toml", "uv.lock" }

local function uv_command(root, executable, args)
	return vim.list_extend({ "uv", "run", "--directory", root, executable }, args or {})
end

local function start_uv_lsp(executable)
	return function(dispatchers, config)
		local root = config.root_dir or vim.uv.cwd()
		return vim.lsp.rpc.start(uv_command(root, executable, { "server" }), dispatchers, { cwd = root })
	end
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				ruff = {
					cmd = start_uv_lsp("ruff"),
					filetypes = { "python" },
					root_markers = root_markers,
					workspace_required = true,
				},
				ty = {
					cmd = start_uv_lsp("ty"),
					filetypes = { "python" },
					root_markers = root_markers,
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
						return uv_command(root, "python")
					end,
				})
			)
		end,
	},
}
