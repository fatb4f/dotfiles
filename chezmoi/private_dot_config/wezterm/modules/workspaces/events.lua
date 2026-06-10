local wezterm = require("wezterm")

local controller = require("modules.workspaces.controller")

local M = {}

function M.setup()
	wezterm.on("term-ide-launch", function(window, pane)
		controller.launch(window, pane)
	end)
end

return M
