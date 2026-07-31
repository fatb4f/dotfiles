local wezterm = require("wezterm")

local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local projects = require("modules.workspaces.projects")

local M = {}

local function home_relative(path)
	if type(path) ~= "string" then
		return path
	end

	if path == wezterm.home_dir then
		return "~"
	end

	if path:sub(1, #wezterm.home_dir + 1) == wezterm.home_dir .. "/" then
		return "~" .. path:sub(#wezterm.home_dir + 1)
	end

	return path
end

local function workspace_exists(name)
	for _, workspace in ipairs(wezterm.mux.get_workspace_names()) do
		if workspace == name then
			return true
		end
	end

	return false
end

local function load_sessions()
	return projects.sessions()
end

local function session_entries()
	local model = load_sessions()
	local entries = {}

	for _, id in ipairs(model.order) do
		local session = model.sessions[id]

		table.insert(entries, {
			id = session.workspace,
			label = string.format("Workspace: '%s'", home_relative(session.workspace)),
		})
	end

	return entries
end

local function switch_to_session(window, pane, session)
	if workspace_exists(session.workspace) then
		window:perform_action(
			wezterm.action.SwitchToWorkspace({
				name = session.workspace,
			}),
			pane
		)
		return
	end

	window:perform_action(
		wezterm.action.SwitchToWorkspace({
			name = session.workspace,
			spawn = {
				cwd = session.cwd,
				set_environment_variables = session.env,
			},
		}),
		pane
	)
end

local function normalized_callback(window, pane, id, label)
	if type(id) ~= "string" then
		return sessionizer.DefaultCallback(window, pane, id, label)
	end

	local model = load_sessions()
	local session = model.sessions[id] or model.sessions_by_workspace[id]

	if session then
		switch_to_session(window, pane, session)
		return
	end

	if workspace_exists(id) then
		window:perform_action(
			wezterm.action.SwitchToWorkspace({
				name = id,
			}),
			pane
		)
		return
	end

	return sessionizer.DefaultCallback(window, pane, id, label)
end

local function schema()
	return {
		options = {
			title = "Session",
			prompt = "Session: ",
			callback = normalized_callback,
		},

		session_entries,
	}
end

function M.apply_to_config(config)
	config.keys = config.keys or {}

	table.insert(config.keys, {
		key = "s",
		mods = "ALT",
		action = sessionizer.show(schema()),
	})

	table.insert(config.keys, {
		key = "9",
		mods = "ALT",
		action = wezterm.action.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	})
end

return M
