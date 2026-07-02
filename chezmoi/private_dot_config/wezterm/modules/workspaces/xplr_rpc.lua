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

local layout_deltas = {
	hide = 80,
	narrow = 8,
	wide = 8,
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

	if payload.op ~= "open" and payload.op ~= "layout" then
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

local function layout_state()
	wezterm.GLOBAL.term_xplr_layout = wezterm.GLOBAL.term_xplr_layout or {}
	return wezterm.GLOBAL.term_xplr_layout
end

local function project_panes(contract)
	local editor = runtime.pane(contract.id, "editor")
	local explorer = runtime.pane(contract.id, "explorer")
	if not editor or not explorer then
		return nil, nil, "project editor/explorer panes are unavailable"
	end

	return editor, explorer, nil
end

local function adjust(window, pane, direction, amount)
	window:perform_action({
		AdjustPaneSize = { direction, amount },
	}, pane)
end

local function activate(pane)
	if pane then
		pane:activate()
	end
end

local function apply_pane_layout(window, contract, kind)
	local editor, explorer, err = project_panes(contract)
	if not editor then
		return false, err
	end

	local state = layout_state()
	state[contract.id] = state[contract.id] or {}
	local project_state = state[contract.id]

	if kind == "hide" then
		adjust(window, editor, "Left", layout_deltas.hide)
		project_state.hidden = true
		activate(editor)
		return true, nil
	end

	if kind == "reveal" then
		adjust(window, editor, "Right", layout_deltas.hide)
		project_state.hidden = false
		activate(explorer)
		return true, nil
	end

	if kind == "narrow" then
		adjust(window, editor, "Left", layout_deltas.narrow)
		project_state.hidden = false
		activate(editor)
		return true, nil
	end

	if kind == "wide" then
		adjust(window, editor, "Right", layout_deltas.wide)
		project_state.hidden = false
		activate(explorer)
		return true, nil
	end

	return false, "unknown explorer layout kind"
end

function M.dispatch(window, pane, payload)
	local contract, contract_err = contract_for(window, pane)
	if not contract then
		notify(window, contract_err)
		return false
	end

	local value, validation_err
	if payload.op == "open" then
		value, validation_err = validate_open(contract, payload)
	elseif payload.op == "layout" then
		value, validation_err = validate_layout(payload)
	else
		validation_err = "unknown xplr operation"
	end

	if not value then
		notify(window, validation_err)
		return false
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
	local value, validation_err = validate_layout({ kind = kind })
	if not value then
		notify(window, validation_err)
		return false
	end

	local contract, contract_err = contract_for(window, pane, { nvim_socket = false })
	if not contract then
		notify(window, contract_err)
		return false
	end

	local ok, err = apply_pane_layout(window, contract, value)
	if not ok then
		notify(window, err)
	end

	return ok
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

local function layout_key(key, kind)
	return {
		key = key,
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			M.dispatch_layout(window, pane, kind)
		end),
	}
end

local function shifted_layout_key(key, kind)
	return {
		key = key,
		mods = "SHIFT",
		action = wezterm.action_callback(function(window, pane)
			M.dispatch_layout(window, pane, kind)
		end),
	}
end

function M.apply_to_config(config)
	config.keys = config.keys or {}

	table.insert(config.keys, layout_key("H", "hide"))
	table.insert(config.keys, layout_key("R", "reveal"))
	table.insert(config.keys, layout_key("N", "narrow"))
	table.insert(config.keys, layout_key("W", "wide"))
	table.insert(config.keys, shifted_layout_key("H", "hide"))
	table.insert(config.keys, shifted_layout_key("R", "reveal"))
	table.insert(config.keys, shifted_layout_key("N", "narrow"))
	table.insert(config.keys, shifted_layout_key("W", "wide"))
end

return M
