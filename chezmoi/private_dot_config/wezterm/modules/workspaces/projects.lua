local wezterm = require("wezterm")

local M = {}

local projects_dir = wezterm.config_dir .. "/modules/projects"

local function adapter(project)
	if type(project.adapters) ~= "table" or type(project.adapters.wezterm) ~= "table" then
		return {}
	end

	return project.adapters.wezterm
end

local function expand_home(path)
	if type(path) ~= "string" then
		return path
	end

	if path:sub(1, 2) == "~/" then
		return wezterm.home_dir .. path:sub(2)
	end

	return path
end

local function basename(path)
	path = tostring(path):gsub("\\", "/")
	return path:match("([^/]+)%.lua$")
end

local function module_name_from_file(path)
	local name = basename(path)

	if not name then
		return nil
	end

	return "modules.projects." .. name
end

local function ensure_table(value, module_name)
	if type(value) ~= "table" then
		error("Invalid workspace project " .. module_name .. ": module must return a table")
	end

	return value
end

local function validate(project, module_name)
	if type(project.id) ~= "string" or project.id == "" then
		error("Invalid workspace project " .. module_name .. ": missing id")
	end

	if type(project.label) ~= "string" or project.label == "" then
		error("Invalid workspace project " .. module_name .. ": missing label")
	end

	project.workspace = project.workspace or project.id

	if type(project.workspace) ~= "string" or project.workspace == "" then
		error("Invalid workspace project " .. module_name .. ": missing workspace")
	end

	project.cwd = project.cwd or project.root

	if type(project.cwd) ~= "string" or project.cwd == "" then
		error("Invalid workspace project " .. module_name .. ": missing cwd/root")
	end

	project.root = project.root or project.cwd

	if project.env == nil then
		project.env = {}
	elseif type(project.env) ~= "table" then
		error("Invalid workspace project " .. module_name .. ": env must be a table")
	end

	project.commands = project.commands or project.panes or {
		{ name = "shell", cmd = nil },
	}

	if type(project.commands) ~= "table" then
		error("Invalid workspace project " .. module_name .. ": commands must be a table")
	end

	return project
end

local function normalize(project)
	project.cwd = expand_home(project.cwd)

	if type(project.root) == "string" then
		project.root = expand_home(project.root)
	end

	for key, value in pairs(project.env) do
		if type(value) == "string" then
			project.env[key] = expand_home(value)
		end
	end

	return project
end

local function session_workspace(project)
	return adapter(project).workspace or project.workspace or project.id
end

local function session_cwd(project)
	return adapter(project).cwd or project.cwd or project.root
end

local function session_env(project)
	local env = {}
	local runtime_dir = os.getenv("XDG_RUNTIME_DIR")

	for key, value in pairs(project.env) do
		if type(key) == "string" and type(value) == "string" then
			env[key] = value
		end
	end

	env.TERM_PROJECT_ID = project.id
	env.TERM_PROJECT_ROOT = project.root or project.cwd
	env.TERM_PROJECT_CWD = session_cwd(project)
	env.TERM_EDITOR = project.editor or env.TERM_EDITOR or "nvim"
	if type(runtime_dir) == "string" and runtime_dir ~= "" then
		env.TERM_NVIM_SOCKET = string.format("%s/nvim/%s.sock", runtime_dir, project.id)
	end

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

local function is_within(root, path)
	return path == root or path:sub(1, #root + 1) == root .. "/"
end

local function sort_projects(a, b)
	if a.workspace == wezterm.home_dir then
		return true
	end

	if b.workspace == wezterm.home_dir then
		return false
	end

	return a.id < b.id
end

function M.list()
	local files = wezterm.glob(projects_dir .. "/*.lua") or {}
	local projects = {}

	table.sort(files)

	for _, file in ipairs(files) do
		local module_name = module_name_from_file(file)

		if module_name then
			local ok, project = pcall(require, module_name)

			if not ok then
				error(
					"Failed to load workspace project " .. module_name .. " from " .. file .. ": " .. tostring(project)
				)
			end

			project = ensure_table(project, module_name)
			validate(project, module_name)
			normalize(project)

			table.insert(projects, project)
		end
	end

	table.sort(projects, sort_projects)

	return projects
end

function M.sessions()
	local model = {
		version = "workspace.projects.v2",
		sessions = {},
		sessions_by_workspace = {},
		order = {},
	}

	for _, project in ipairs(M.list()) do
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

function M.session_for_path(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end

	local matched = nil

	for _, session in pairs(M.sessions().sessions) do
		if session.root ~= wezterm.home_dir and is_within(session.root, path) then
			if not matched or #session.root > #matched.root then
				matched = session
			end
		end
	end

	return matched
end

function M.by_id()
	local index = {}

	for _, project in ipairs(M.list()) do
		if index[project.id] then
			error("Duplicate workspace project id: " .. project.id)
		end

		index[project.id] = project
	end

	return index
end

M.index = M.by_id

return M
