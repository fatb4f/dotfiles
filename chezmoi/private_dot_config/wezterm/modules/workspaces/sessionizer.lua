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

local function adapter(project)
	if type(project.adapters) ~= "table" then
		return {}
	end

	if type(project.adapters.wezterm) ~= "table" then
		return {}
	end

	return project.adapters.wezterm
end

local function session_workspace(project)
	return adapter(project).workspace or project.workspace or project.id
end

local function session_cwd(project)
	return adapter(project).cwd or project.cwd or project.root
end

local function session_env(project)
	local env = {}

	if type(project.env) == "table" then
		for key, value in pairs(project.env) do
			if type(key) == "string" and type(value) == "string" then
				env[key] = value
			end
		end
	end

	env.TERM_PROJECT_ID = project.id
	env.TERM_PROJECT_ROOT = project.root or project.cwd
	env.TERM_PROJECT_CWD = session_cwd(project)
	env.TERM_EDITOR = project.editor or env.TERM_EDITOR or "nvim"

	return env
end

local function normalize_session(project)
	return {
		id = project.id,
		label = project.label,
		kind = project.kind or "project",
		intent = project.intent,
		root = project.root or project.cwd,
		workspace = session_workspace(project),
		cwd = session_cwd(project),
		editor = project.editor or "nvim",
		env = session_env(project),
		commands = project.commands or {},
		raw = project,
	}
end

local function load_sessions()
	local model = {
		version = "workspace.projects.v2",
		sessions = {},
		sessions_by_workspace = {},
		order = {},
	}

	for _, project in ipairs(projects.list()) do
		local session = normalize_session(project)

		if model.sessions[session.id] then
			error("Duplicate workspace project id: " .. session.id)
		end

		if model.sessions_by_workspace[session.workspace] then
			error("Duplicate workspace project workspace: " .. session.workspace)
		end

		model.sessions[session.id] = session
		model.sessions_by_workspace[session.workspace] = session
		table.insert(model.order, session.id)
	end

	return model
end

local function session_entries(model)
	local entries = {}

	for _, id in ipairs(model.order) do
		local session = model.sessions[id]

		table.insert(entries, {
			id = session.workspace,
			label = session.workspace,
		})
	end

	return entries
end

local function normalize_entries(entries)
	local seen = {}
	local next_index = 1

	for _, entry in ipairs(entries) do
		if type(entry.id) == "string" and not seen[entry.id] then
			seen[entry.id] = true
			entry.label = string.format("Workspace: '%s'", home_relative(entry.id))
			entries[next_index] = entry
			next_index = next_index + 1
		end
	end

	for index = #entries, next_index, -1 do
		entries[index] = nil
	end

	table.sort(entries, function(a, b)
		if a.id == wezterm.home_dir then
			return true
		end

		if b.id == wezterm.home_dir then
			return false
		end

		return a.id < b.id
	end)
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
	local model = load_sessions()

	return {
		options = {
			title = "Session",
			prompt = "Session: ",
			callback = normalized_callback,
		},

		sessionizer.AllActiveWorkspaces({
			filter_current = true,
			filter_default = true,
		}),

		session_entries(model),

		processing = normalize_entries,
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
