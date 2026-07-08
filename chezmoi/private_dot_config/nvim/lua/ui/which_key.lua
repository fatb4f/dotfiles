-- lua/ui/which_key.lua

local M = {}

function M.setup()
	require("which-key").setup({
		preset = "modern",
		delay = 300,
		icons = {
			mappings = false,
		},
	})
end

return M
