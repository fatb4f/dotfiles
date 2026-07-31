local wezterm = require("wezterm")

local function config_home()
	return os.getenv("XDG_CONFIG_HOME") or wezterm.home_dir .. "/.config"
end

local function trim(value)
	return value:match("^%s*(.-)%s*$")
end

local function expand_home(path)
	if path == "~" then
		return wezterm.home_dir
	end

	if path:sub(1, 2) == "~/" then
		return wezterm.home_dir .. path:sub(2)
	end

	if path:sub(1, 1) == "/" then
		return path
	end

	error("Invalid project seed path: " .. path .. "; expected ~, ~/..., or an absolute path")
end

local function normalize_path(path)
	if path ~= "/" then
		path = path:gsub("/+$", "")
	end

	return path
end

local function basename(path)
	return path:match("([^/]+)$")
end

local function seed_paths()
	local seed_path = config_home() .. "/projects.seed"
	local file, err = io.open(seed_path, "r")

	if not file then
		error("Unable to read project seed " .. seed_path .. ": " .. tostring(err))
	end

	local paths = {}

	for line in file:lines() do
		local path = trim(line)

		if path ~= "" and path:sub(1, 1) ~= "#" then
			table.insert(paths, normalize_path(expand_home(path)))
		end
	end

	file:close()

	return paths
end

local function session_for_path(path)
	local is_home = path == wezterm.home_dir
	local id = is_home and "home" or basename(path)

	if not id or id == "" then
		error("Invalid project seed path: " .. path)
	end

	return {
		id = id,
		label = is_home and "~" or id,
		kind = "project",
		root = path,
		workspace = is_home and wezterm.home_dir or id,
		cwd = path,
		editor = "nvim",
		env = {
			TERM_PROJECT_ID = id,
			TERM_PROJECT_ROOT = path,
			TERM_PROJECT_CWD = path,
			TERM_EDITOR = "nvim",
		},
	}
end

local function load()
	local model = {
		version = "workspace.projects.v3",
		sessions = {},
		sessions_by_workspace = {},
		order = {},
	}
	local roots = {}

	for _, path in ipairs(seed_paths()) do
		local session = session_for_path(path)

		if roots[path] then
			error("Duplicate project seed path: " .. path)
		end

		if model.sessions[session.id] then
			error("Duplicate project seed id: " .. session.id)
		end

		if model.sessions_by_workspace[session.workspace] then
			error("Duplicate project seed workspace: " .. session.workspace)
		end

		roots[path] = true
		model.sessions[session.id] = session
		model.sessions_by_workspace[session.workspace] = session
		table.insert(model.order, session.id)
	end

	return model
end

return { load = load }
