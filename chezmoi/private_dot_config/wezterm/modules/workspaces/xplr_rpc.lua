local wezterm = require("wezterm")

local projects = require("modules.workspaces.projects")
local runtime = require("modules.workspaces.runtime")

local M = {}

local layout_kinds = {
	hide = true,
	reveal = true,
	narrow = true,
	wide = true,
}

local function notify(window, message)
	window:toast_notification("Xplr RPC", message, nil, 5000)
end

local function is_dir(path)
	local ok, entries = pcall(wezterm.read_dir, path)
	return ok and entries ~= nil
end

local function canonical_path(path)
	if type(path) ~= "string" or path:sub(1, 1) ~= "/" then
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

local function path_is_socket(path)
	local success = wezterm.run_child_process({ "test", "-S", path })
	return success
end

local function pane_cwd(pane)
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

local function active_session(window, pane)
	local workspace = window:active_workspace()
	local cached = runtime.session_for_workspace(workspace)
	local cwd = pane_cwd(pane)
	local detected = cwd and projects.session_for_path(cwd) or nil

	if not detected then
		local canonical_cwd = canonical_path(cwd)
		detected = canonical_cwd and projects.session_for_path(canonical_cwd) or nil
	end

	if detected and (not cached or detected.id ~= cached.id) then
		return detected
	end

	return cached
end

local function contract_for(window, pane, opts)
	opts = opts or {}

	local session = active_session(window, pane)
	if type(session) ~= "table" then
		return nil, "active workspace is not a configured project session"
	end

	local root = canonical_path(session.root)
	if not root or not is_dir(root) then
		return nil, "TERM_PROJECT_ROOT must be an existing absolute directory"
	end

	if opts.nvim_socket == false then
		return {
			editor = session.editor or "nvim",
			id = session.id,
			root = root,
			socket = session.env and session.env.TERM_NVIM_SOCKET or nil,
		}
	end

	if type(session.env) ~= "table" or type(session.env.TERM_NVIM_SOCKET) ~= "string" then
		return nil, "TERM_NVIM_SOCKET is not configured"
	end

	if not path_is_socket(session.env.TERM_NVIM_SOCKET) then
		return nil, "Neovim socket is unavailable: " .. session.env.TERM_NVIM_SOCKET
	end

	return {
		editor = session.editor or "nvim",
		id = session.id,
		root = root,
		socket = session.env.TERM_NVIM_SOCKET,
	}
end

local function lua_quote(value)
	return string.format("%q", tostring(value))
end

local function sh_quote(value)
	return "'" .. tostring(value):gsub("'", "'\"'\"'") .. "'"
end

local function nvim_dispatch(contract, op, value)
	local expr = string.format("v:lua.TermXplrMuxRpc(%s, %s)", lua_quote(op), lua_quote(value))
	return wezterm.run_child_process({
		contract.editor,
		"--server",
		contract.socket,
		"--remote-expr",
		expr,
	})
end

local function nvim_accepted(stdout)
	local returned = tostring(stdout or ""):gsub("%s+$", "")
	return returned == "1" or returned == "true" or returned == "v:true"
end

local function decode_payload(value)
	if type(value) ~= "string" or value == "" then
		return nil, "empty TERM_XPLR_RPC payload"
	end

	local ok, payload = pcall(wezterm.json_parse, value)
	if not ok or type(payload) ~= "table" then
		local decoded_ok, stdout = wezterm.run_child_process({
			"bash",
			"-lc",
			"printf '%s' \"$1\" | base64 --decode",
			"bash",
			value,
		})
		if decoded_ok and type(stdout) == "string" and stdout ~= "" then
			ok, payload = pcall(wezterm.json_parse, stdout)
		end
	end

	if not ok or type(payload) ~= "table" then
		return nil, "TERM_XPLR_RPC payload must be JSON"
	end

	if payload.op ~= "open" and payload.op ~= "layout" and payload.op ~= "preview" then
		return nil, "unknown xplr operation"
	end

	return payload, nil
end

local function validate_open(contract, payload)
	local path = canonical_path(payload.path)
	if not path then
		return nil, "open path must be an existing absolute path"
	end

	if not is_within(contract.root, path) then
		return nil, "open path is outside TERM_PROJECT_ROOT"
	end

	return path, nil
end

local function validate_layout(payload)
	if not layout_kinds[payload.kind] then
		return nil, "unknown explorer layout kind"
	end

	return payload.kind, nil
end

local function validate_preview(contract, payload)
	if payload.state ~= "on" and payload.state ~= "off" then
		return nil, "unknown preview state"
	end

	if payload.state == "off" then
		return {
			state = "off",
		}, nil
	end

	local fifo_path = payload.fifoPath
	if type(fifo_path) ~= "string" or fifo_path:sub(1, 1) ~= "/" then
		return nil, "preview fifo path must be absolute"
	end

	local runtime_dir = os.getenv("XDG_RUNTIME_DIR")
	if type(runtime_dir) ~= "string" or runtime_dir == "" then
		return nil, "XDG_RUNTIME_DIR is required for preview fifo"
	end

	local expected_dir = runtime_dir .. "/term-xplr-preview"
	local expected_path = expected_dir .. "/" .. contract.id .. ".fifo"
	if fifo_path ~= expected_path then
		return nil, "preview fifo path does not match the active project"
	end

	return {
		state = "on",
		fifo_path = fifo_path,
		fifo_dir = expected_dir,
		ready_path = fifo_path .. ".ready",
	},
		nil
end

local function ensure_fifo(preview)
	local ok, _, stderr = wezterm.run_child_process({ "mkdir", "-p", preview.fifo_dir })
	if not ok then
		return false, stderr
	end

	local is_fifo = wezterm.run_child_process({ "test", "-p", preview.fifo_path })
	if is_fifo then
		return true, nil
	end

	local exists = wezterm.run_child_process({ "test", "-e", preview.fifo_path })
	if exists then
		local removed, remove_err = os.remove(preview.fifo_path)
		if not removed then
			return false, remove_err
		end
	end

	ok, _, stderr = wezterm.run_child_process({ "mkfifo", preview.fifo_path })
	if not ok then
		return false, stderr
	end

	return true, nil
end

local function preview_reader()
	return wezterm.home_dir .. "/.local/bin/term-xplr-preview"
end

local function remove_ready_marker(preview)
	os.remove(preview.ready_path)
end

local function preview_reader_command(reader, contract, preview)
	return table.concat({
		"cd " .. sh_quote(contract.root),
		"TERM_PROJECT_ID="
			.. sh_quote(contract.id)
			.. " TERM_PROJECT_ROOT="
			.. sh_quote(contract.root)
			.. " "
			.. sh_quote(reader)
			.. " "
			.. sh_quote(contract.root)
			.. " "
			.. sh_quote(preview.fifo_path)
			.. " "
			.. sh_quote(preview.ready_path),
	}, " && ") .. "\n"
end

local function ensure_preview_pane(window, pane, contract, preview)
	local reader = preview_reader()
	if not wezterm.run_child_process({ "test", "-x", reader }) then
		return false, "Preview reader is unavailable: " .. reader
	end

	remove_ready_marker(preview)

	local ready, fifo_err = ensure_fifo(preview)
	if not ready then
		return false, "Unable to prepare preview FIFO: " .. tostring(fifo_err)
	end

	local preview_pane = runtime.pane(contract.id, "preview")
	if not preview_pane then
		local split_ok, split_or_err = pcall(pane.split, pane, {
			direction = "Right",
			size = 0.35,
			cwd = contract.root,
			set_environment_variables = {
				TERM_PROJECT_ID = contract.id,
				TERM_PROJECT_ROOT = contract.root,
			},
		})
		if not split_ok then
			return false, "Unable to create preview pane: " .. tostring(split_or_err)
		end

		preview_pane = split_or_err
		runtime.remember_pane(contract.id, "preview", preview_pane)
	else
		preview_pane:send_text("\003")
	end

	preview_pane:send_text(preview_reader_command(reader, contract, preview))

	pane:activate()
	return true, nil
end

local function stop_preview_pane(pane, contract)
	local runtime_dir = os.getenv("XDG_RUNTIME_DIR")
	if type(runtime_dir) == "string" and runtime_dir ~= "" then
		os.remove(runtime_dir .. "/term-xplr-preview/" .. contract.id .. ".fifo.ready")
	end

	local preview_pane = runtime.pane(contract.id, "preview")
	if preview_pane then
		preview_pane:send_text("\003")
	end

	pane:activate()
	return true, nil
end

function M.dispatch(window, pane, payload)
	local contract, contract_err = contract_for(window, pane, {
		nvim_socket = payload.op ~= "preview",
	})
	if not contract then
		notify(window, contract_err)
		return false
	end

	local value, validation_err
	if payload.op == "open" then
		value, validation_err = validate_open(contract, payload)
	elseif payload.op == "layout" then
		value, validation_err = validate_layout(payload)
	elseif payload.op == "preview" then
		value, validation_err = validate_preview(contract, payload)
	else
		validation_err = "unknown xplr operation"
	end

	if not value then
		notify(window, validation_err)
		return false
	end

	if payload.op == "preview" then
		local ok, err
		if value.state == "on" then
			ok, err = ensure_preview_pane(window, pane, contract, value)
		else
			ok, err = stop_preview_pane(pane, contract)
		end

		if not ok then
			notify(window, err)
			return false
		end

		return true
	end

	local success, stdout, stderr = nvim_dispatch(contract, payload.op, value)
	if not success then
		notify(window, "Neovim RPC failed: " .. tostring(stderr))
		return false
	end

	if not nvim_accepted(stdout) then
		notify(window, "Neovim RPC rejected operation: " .. tostring(stdout))
		return false
	end

	return true
end

function M.dispatch_layout(window, pane, kind)
	return M.dispatch(window, pane, {
		op = "layout",
		kind = kind,
	})
end

function M.handle_user_var(window, pane, name, value)
	if name ~= "TERM_XPLR_RPC" then
		return
	end

	local payload, err = decode_payload(value)
	if not payload then
		notify(window, err)
		return
	end

	M.dispatch(window, pane, payload)
end

return M
