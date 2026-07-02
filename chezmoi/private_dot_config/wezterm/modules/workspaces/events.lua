local wezterm = require("wezterm")

local controller = require("modules.workspaces.controller")
local project_tree_visibility = require("modules.workspaces.project_tree_visibility")
local xplr_rpc = require("modules.workspaces.xplr_rpc")

local M = {}

function M.setup()
	wezterm.on("term-ide-launch", function(window)
		controller.launch(window)
	end)

	for _, action in ipairs({ "hide", "reveal" }) do
		wezterm.on("term-project-tree-" .. action, function(window, pane)
			project_tree_visibility.dispatch(window, pane, action)
		end)
	end

	wezterm.on("user-var-changed", function(window, pane, name, value)
		xplr_rpc.handle_user_var(window, pane, name, value)
	end)
end

return M
