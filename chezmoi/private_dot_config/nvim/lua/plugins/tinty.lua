return {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				if not require("ui.tinty").reload() then
					vim.cmd.colorscheme("habamax")
				end
			end,
		},
	},
}
