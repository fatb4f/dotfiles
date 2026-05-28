local wezterm = require("wezterm")

local projects = require("modules.projects")

local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local history = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-history.git")
local zoxide = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-zoxide.git")

local M = {}

local fd_roots = {
	wezterm.home_dir .. "/src",
	wezterm.home_dir .. "/work",
	wezterm.home_dir .. "/dev",
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
			callback = history.Wrapper(sessionizer.DefaultCallback),
		},

		history.MostRecentWorkspace({}),
		sessionizer.AllActiveWorkspaces({
			filter_current = true,
			filter_default = true,
		}),
		project_entries(),

		processing = sessionizer.for_each_entry(function(entry)
			entry.label = entry.label:gsub(wezterm.home_dir, "~")
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
