local wezterm = require("wezterm")

local runtime = require("modules.workspaces.runtime")

local M = {}

local function notify(window, title, message)
	window:toast_notification(title, message, nil, 5000)
end

local function is_dir(path)
	local ok, entries = pcall(wezterm.read_dir, path)
	return ok and entries ~= nil
end

local function normalized_dir(path)
	if path == "/" then
		return path
	end
	return path:gsub("/+$", "")
end

local function is_within(root, path)
	root = normalized_dir(root)
	path = normalized_dir(path)
	return path == root or path:sub(1, #root + 1) == root .. "/"
end

local function validate(session)
	if type(session) ~= "table" then
		return nil, "active workspace is not a configured project session"
	end

	if type(session.id) ~= "string" or not session.id:match("^[%w._-]+$") then
		return nil, "invalid TERM_PROJECT_ID"
	end

	if type(session.root) ~= "string" or session.root:sub(1, 1) ~= "/" or not is_dir(session.root) then
		return nil, "TERM_PROJECT_ROOT must be an existing absolute directory"
	end

	if type(session.cwd) ~= "string" or session.cwd:sub(1, 1) ~= "/" or not is_dir(session.cwd) then
		return nil, "TERM_PROJECT_CWD must be an existing absolute directory"
	end

	if not is_within(session.root, session.cwd) then
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

	return {
		id = session.id,
		root = normalized_dir(session.root),
		cwd = normalized_dir(session.cwd),
		workspace = session.workspace,
		editor = session.editor or "nvim",
		env = session.env,
		runtime_dir = runtime_dir,
		socket_dir = runtime_dir .. "/nvim",
		socket = expected_socket,
	}, nil
end

local function nvim_alive(contract)
	local success = wezterm.run_child_process({
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

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function editor_command(contract)
	return table.concat({
		"exec",
		shell_quote(contract.editor),
		"--listen",
		shell_quote(contract.socket),
	}, " ") .. "\n"
end

local function pane_runs_shell(pane)
	local process = pane:get_foreground_process_name() or ""
	local name = process:match("([^/]+)$") or process
	return name == "bash" or name == "fish" or name == "nu" or name == "zsh"
end

local function focus_cached_editor(contract)
	local editor = runtime.pane(contract.id, "editor")
	if not editor then
		return false
	end

	editor:activate()
	return true
end

function M.launch(window, pane)
	local workspace = window:active_workspace()
	local contract, err = validate(runtime.session_for_workspace(workspace))
	if not contract then
		notify(window, "IDE launch", err)
		return
	end

	if nvim_alive(contract) then
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

	local editor = runtime.pane(contract.id, "editor") or pane
	local explorer = runtime.pane(contract.id, "explorer")

	if not pane_runs_shell(editor) then
		notify(window, "IDE launch", "Launch the IDE from a project shell pane")
		return
	end

	if not explorer then
		local split_ok, split_result = pcall(editor.split, editor, {
			direction = "Left",
			size = 0.2,
			cwd = contract.root,
			args = { "xplr", contract.root },
			set_environment_variables = contract.env,
		})
		if not split_ok then
			notify(window, "IDE launch", "Unable to launch Xplr: " .. tostring(split_result))
			return
		end
		explorer = split_result
		runtime.remember_pane(contract.id, "explorer", explorer)
	end

	runtime.remember_pane(contract.id, "editor", editor)
	editor:send_text(editor_command(contract))
	editor:activate()
end

return M
