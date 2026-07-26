local function session_root()
	local root = vim.env.TERM_PROJECT_ROOT
	if type(root) == "string" and root ~= "" and vim.fn.isdirectory(root) == 1 then
		return root
	end

	return LazyVim.root()
end

return {
	{
		"folke/snacks.nvim",
		opts = {
			dashboard = {
				enabled = true,
			},
			explorer = {
				enabled = true,
				replace_netrw = true,
				hidden = true,
			},
			picker = {
				sources = {
					explorer = {
						layout = {
							preset = "sidebar",
							preview = "main",
						},
					},
				},
				hidden = true,
			},
		},
		keys = {
			{
				"<leader>fe",
				function()
					Snacks.explorer({ cwd = session_root() })
				end,
				desc = "Explorer Snacks (root dir)",
			},
			{
				"<leader>fE",
				function()
					Snacks.explorer()
				end,
				desc = "Explorer Snacks (cwd)",
			},
			{ "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
			{ "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
		},
	},
}
