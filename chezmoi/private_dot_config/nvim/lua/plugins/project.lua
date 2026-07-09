return {
	{
		"folke/snacks.nvim",
		opts = function(_, opts)
			opts.dashboard = opts.dashboard or {}
			opts.dashboard.preset = opts.dashboard.preset or {}

			local project = vim.env.TERM_PROJECT_ID
			local root = vim.env.TERM_PROJECT_ROOT
			if project and root then
				opts.dashboard.preset.header = table.concat({
					project,
					"",
					"root: " .. root,
				}, "\n")
				return
			end

			opts.dashboard.preset.header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]
		end,
	},
}
