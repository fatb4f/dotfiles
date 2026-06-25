local wezterm = require("wezterm")

local controller = require("modules.workspaces.controller")
local xplr_rpc = require("modules.workspaces.xplr_rpc")

local M = {}

function M.setup()
	wezterm.on("term-ide-launch", function(window)
		controller.launch(window)
	end)

	for _, kind in ipairs({ "hide", "reveal", "narrow", "wide" }) do
		wezterm.on("term-xplr-layout-" .. kind, function(window, pane)
			xplr_rpc.dispatch_layout(window, pane, kind)
		end)
	end

	wezterm.on("user-var-changed", function(window, pane, name, value)
		xplr_rpc.handle_user_var(window, pane, name, value)
	end)
end

return M
