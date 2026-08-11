local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local workspace = "python-learning"
local root = wezterm.home_dir .. "/src/python"

local function workspace_exists()
	for _, name in ipairs(wezterm.mux.get_workspace_names()) do
		if name == workspace then
			return true
		end
	end

	return false
end

local function environment()
	return {
		EDITOR = "helix",
		VISUAL = "helix",
		TERM_EDITOR = "helix",
		TERM_PROJECT_ID = "python",
		TERM_PROJECT_ROOT = root,
		TERM_PROJECT_CWD = root,
	}
end

local function open_workspace()
	return wezterm.action_callback(function(window, pane)
		if workspace_exists() then
			window:perform_action(act.SwitchToWorkspace({ name = workspace }), pane)
			return
		end

		window:perform_action(
			act.SwitchToWorkspace({
				name = workspace,
				spawn = {
					cwd = root,
					set_environment_variables = environment(),
				},
			}),
			pane
		)

		local terminal = window:active_pane()
		window:perform_action(
			act.SplitPane({
				direction = "Left",
				size = { Percent = 50 },
				command = {
					args = { "helix", "." },
					cwd = root,
					set_environment_variables = environment(),
				},
			}),
			terminal
		)
	end)
end

function M.apply_to_config(config)
	config.keys = config.keys or {}

	table.insert(config.keys, {
		key = "p",
		mods = "ALT",
		action = open_workspace(),
	})

	wezterm.on("augment-command-palette", function()
		return {
			{
				brief = "Open Python learning workspace",
				doc = "Open Helix and a terminal in ~/src/python",
				action = open_workspace(),
			},
		}
	end)
end

return M
