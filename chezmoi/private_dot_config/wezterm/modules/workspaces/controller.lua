local wezterm = require("wezterm")

local projects = require("modules.workspaces.projects")
local runtime = require("modules.workspaces.runtime")

local M = {}

local function notify(window, title, message)
	window:toast_notification(title, message, nil, 5000)
end

local function is_dir(path)
	local ok, entries = pcall(wezterm.read_dir, path)
	return ok and entries ~= nil
end

local function canonical_dir(path)
	if type(path) ~= "string" or path:sub(1, 1) ~= "/" or not is_dir(path) then
		return nil
	end

	local success, stdout = wezterm.run_child_process({ "realpath", "--canonicalize-existing", path })
	if not success then
		return nil
	end

	local canonical = stdout:gsub("%s+$", "")
	if canonical == "" or canonical:sub(1, 1) ~= "/" then
		return nil
	end

	return canonical
end

local function is_within(root, path)
	return path == root or path:sub(1, #root + 1) == root .. "/"
end

local function pane_cwd(window)
	local pane = window:active_pane()
	if not pane then
		return nil
	end

	local cwd = pane:get_current_working_dir()
	if not cwd then
		return nil
	end

	local has_file_path, file_path = pcall(function()
		return cwd.file_path
	end)
	if has_file_path and type(file_path) == "string" then
		return file_path
	end

	return tostring(cwd):match("^file://[^/]*(/.*)$")
end

local function configured_session_for_workspace(workspace)
	if type(workspace) ~= "string" or workspace == "" then
		return nil
	end

	return projects.sessions().sessions_by_workspace[workspace]
end

local function active_session(window, workspace)
	local cwd = pane_cwd(window)
	local detected = cwd and projects.session_for_path(cwd) or nil

	if not detected then
		local canonical_cwd = canonical_dir(cwd)
		detected = canonical_cwd and projects.session_for_path(canonical_cwd) or nil
	end

	if detected then
		return detected
	end

	return configured_session_for_workspace(workspace)
end

local function validate(session)
	if type(session) ~= "table" then
		return nil, "active workspace is not a configured project session"
	end

	if type(session.id) ~= "string" or not session.id:match("^[%w._-]+$") then
		return nil, "invalid TERM_PROJECT_ID"
	end

	local root = canonical_dir(session.root)
	if not root then
		return nil, "TERM_PROJECT_ROOT must be an existing absolute directory"
	end

	local cwd = canonical_dir(session.cwd)
	if not cwd then
		return nil, "TERM_PROJECT_CWD must be an existing absolute directory"
	end

	if not is_within(root, cwd) then
		return nil, "TERM_PROJECT_CWD must be inside TERM_PROJECT_ROOT"
	end

	local runtime_dir = os.getenv("XDG_RUNTIME_DIR")
	if type(runtime_dir) ~= "string" or runtime_dir == "" or not is_dir(runtime_dir) then
		return nil, "XDG_RUNTIME_DIR must be an existing directory"
	end

	local expected_socket = string.format("%s/nvim/%s.sock", runtime_dir, session.id)
	if type(session.env) ~= "table" or session.env.TERM_NVIM_SOCKET ~= expected_socket then
		return nil, "TERM_NVIM_SOCKET does not match TERM_PROJECT_ID"
	end

	local env = {}
	for key, value in pairs(session.env) do
		env[key] = value
	end
	env.TERM_PROJECT_ROOT = root
	env.TERM_PROJECT_CWD = cwd

	return {
		id = session.id,
		root = root,
		cwd = cwd,
		workspace = session.workspace,
		editor = session.editor or "nvim",
		env = env,
		runtime_dir = runtime_dir,
		socket_dir = runtime_dir .. "/nvim",
		socket = expected_socket,
	},
		nil
end

local function nvim_alive(contract)
	local success = wezterm.run_child_process({
		"timeout",
		"0.35",
		contract.editor,
		"--server",
		contract.socket,
		"--remote-expr",
		"1",
	})
	return success
end

local function path_is_socket(path)
	local success = wezterm.run_child_process({ "test", "-S", path })
	return success
end

local function ensure_socket_dir(contract)
	local success, _, stderr = wezterm.run_child_process({ "mkdir", "-p", contract.socket_dir })
	if not success then
		return false, stderr
	end
	return true, nil
end

local function focus_cached_editor(contract)
	local editor = runtime.pane(contract.id, "editor")
	if not editor then
		return false
	end

	editor:activate()
	return true
end

local function spawn_editor(window, contract)
	local mux_window = window:mux_window()
	local spawn_ok, tab_or_err, editor = pcall(mux_window.spawn_tab, mux_window, {
		cwd = contract.cwd,
		args = { contract.editor, "--listen", contract.socket },
		set_environment_variables = contract.env,
	})
	if not spawn_ok then
		return nil, tab_or_err
	end

	return editor, nil
end

local function command_args(command)
	if command.cmd == nil then
		return nil
	end

	if type(command.cmd) == "table" then
		return command.cmd
	end

	return { "sh", "-lc", tostring(command.cmd) }
end

local function command_by_name(session, name)
	if type(session) ~= "table" or type(name) ~= "string" or name == "" or type(session.commands) ~= "table" then
		return nil
	end

	for _, command in ipairs(session.commands) do
		if type(command) == "table" and command.name == name then
			return command
		end
	end

	return nil
end

local function spawn_project_command(window, contract, command)
	local mux_window = window:mux_window()
	local spawn_ok, tab_or_err, pane = pcall(mux_window.spawn_tab, mux_window, {
		cwd = contract.cwd,
		args = command_args(command),
		set_environment_variables = contract.env,
	})
	if not spawn_ok then
		return nil, tab_or_err
	end

	runtime.remember_pane(contract.id, command.name, pane)
	return pane, nil
end

function M.launch(window)
	local workspace = window:active_workspace()
	local session = active_session(window, workspace)
	local contract, err = validate(session)
	if not contract then
		notify(window, "IDE launch", err)
		return
	end

	runtime.remember_session(session)

	if nvim_alive(contract) then
		-- A live socket can outlast the mux pane cached when the editor was spawned.
		-- Do not start a second editor; report the split-brain state for recovery.
		if not focus_cached_editor(contract) then
			notify(window, "IDE launch", "Neovim is alive, but its pane is not available in the runtime cache")
		end
		return
	end

	if path_is_socket(contract.socket) then
		local removed, remove_err = os.remove(contract.socket)
		if not removed then
			notify(window, "IDE launch", "Unable to remove stale Neovim socket: " .. tostring(remove_err))
			return
		end
	end

	local ready, mkdir_err = ensure_socket_dir(contract)
	if not ready then
		notify(window, "IDE launch", "Unable to create Neovim runtime directory: " .. tostring(mkdir_err))
		return
	end

	local editor, spawn_err = spawn_editor(window, contract)
	if not editor then
		notify(window, "IDE launch", "Unable to launch Neovim: " .. tostring(spawn_err))
		return
	end

	runtime.remember_pane(contract.id, "editor", editor)

	local split_ok, explorer = pcall(editor.split, editor, {
		direction = "Left",
		size = 0.2,
		cwd = contract.root,
		args = { "xplr", "--config", wezterm.home_dir .. "/.config/xplr/init.lua", contract.root },
		set_environment_variables = contract.env,
	})
	if not split_ok then
		notify(window, "IDE launch", "Neovim launched, but Xplr failed: " .. tostring(explorer))
		editor:activate()
		return
	end

	runtime.remember_pane(contract.id, "explorer", explorer)
	editor:activate()
end

function M.launch_command(window, name)
	local workspace = window:active_workspace()
	local session = active_session(window, workspace)
	local command = command_by_name(session, name)
	if not command then
		notify(window, "Project command", "No project command named: " .. tostring(name))
		return
	end

	local contract, err = validate(session)
	if not contract then
		notify(window, "Project command", err)
		return
	end

	runtime.remember_session(session)

	local pane, spawn_err = spawn_project_command(window, contract, command)
	if not pane then
		notify(window, "Project command", "Unable to launch " .. name .. ": " .. tostring(spawn_err))
		return
	end

	pane:activate()
end

return M
