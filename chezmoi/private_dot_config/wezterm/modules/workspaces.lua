local wezterm = require("wezterm")

local projects = require("modules.projects")

local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local history = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-history.git")
local zoxide = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-zoxide.git")

local M = {}

local fd_roots = {
	wezterm.home_dir .. "/src",
}

local fd_excludes = {
	"node_modules",
	".cache",
	".venv",
	"target",
	"vendor",
}

local function is_dir(path)
	local ok, entries = pcall(wezterm.read_dir, path)
	return ok and entries ~= nil
end

local function basename(path)
	local trimmed = path:gsub("/+$", "")
	return trimmed:match("([^/]+)$") or trimmed
end

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

local function is_abs_path(value)
	return type(value) == "string" and value:sub(1, 1) == "/"
end

local function expand_home(path)
	if type(path) == "string" and path:sub(1, 2) == "~/" then
		return wezterm.home_dir .. path:sub(2)
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

local function normalize_dir_candidate(id, label)
	local cwd = expand_home(id)
	if not is_abs_path(cwd) or not is_dir(cwd) then
		return nil
	end

	return {
		workspace = basename(cwd),
		cwd = cwd,
		label = label or home_relative(cwd),
	}
end

local function normalized_callback(window, pane, id, label)
	if type(id) ~= "string" then
		return sessionizer.DefaultCallback(window, pane, id, label)
	end

	if workspace_exists(id) then
		window:perform_action(wezterm.action.SwitchToWorkspace({ name = id }), pane)
		return
	end

	local candidate = normalize_dir_candidate(id, label)
	if not candidate then
		return sessionizer.DefaultCallback(window, pane, id, label)
	end

	window:perform_action(
		wezterm.action.SwitchToWorkspace({
			name = candidate.workspace,
			spawn = {
				cwd = candidate.cwd,
				set_environment_variables = {
					TERM_PROJECT_ROOT = candidate.cwd,
				},
			},
		}),
		pane
	)
end

local function project_entries()
	local names = {}
	for name, project in pairs(projects) do
		if type(project.root) == "string" and is_dir(project.root) then
			table.insert(names, name)
		end
	end
	table.sort(names)

	local entries = {}
	for _, name in ipairs(names) do
		local project = projects[name]
		table.insert(entries, {
			label = name .. " (" .. project.root .. ")",
			id = project.root,
		})
	end

	return entries
end

local function fd_searches()
	local searches = {}

	for _, root in ipairs(fd_roots) do
		if is_dir(root) then
			table.insert(
				searches,
				sessionizer.FdSearch({
					root,
					exclude = fd_excludes,
				})
			)
		end
	end

	return searches
end

local function workspace_schema()
	local schema = {
		options = {
			title = "Workspace",
			prompt = "Workspace: ",
			callback = history.Wrapper(normalized_callback),
		},

		history.MostRecentWorkspace({}),
		sessionizer.AllActiveWorkspaces({
			filter_current = true,
			filter_default = true,
		}),
		project_entries(),

		processing = sessionizer.for_each_entry(function(entry)
			if type(entry.label) == "string" then
				entry.label = home_relative(entry.label)
			end
		end),
	}

	for _, search in ipairs(fd_searches()) do
		table.insert(schema, search)
	end

	table.insert(schema, zoxide.Zoxide({}))

	return schema
end

function M.apply_to_config(config)
	config.keys = config.keys or {}

	table.insert(config.keys, {
		key = "s",
		mods = "ALT",
		action = sessionizer.show(workspace_schema()),
	})

	table.insert(config.keys, {
		key = "m",
		mods = "ALT",
		action = history.switch_to_most_recent_workspace,
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
