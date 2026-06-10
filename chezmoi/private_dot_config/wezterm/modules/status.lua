local wezterm = require("wezterm")

local M = {}

function M.apply_to_config()
	wezterm.on("update-right-status", function(window)
		window:set_right_status(" " .. window:active_workspace() .. " ")
	end)
end

return M
