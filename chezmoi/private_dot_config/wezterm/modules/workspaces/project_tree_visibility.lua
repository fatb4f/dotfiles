local wezterm = require("wezterm")

local projects = require("modules.workspaces.projects")
local runtime = require("modules.workspaces.runtime")

local M = {}

local mutation_delay = 0.05

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

	if cached then
		return cached
	end

	local configured = projects.sessions()
	local workspace_session = configured.sessions_by_workspace[workspace]
	if workspace_session then
		return workspace_session
	end

	local pane_project_id = runtime.project_for_pane(pane)
	if pane_project_id then
		return runtime.session_for_project(pane_project_id) or configured.sessions[pane_project_id]
	end

	return nil
end

local function pane_id(pane)
	local ok, id = pcall(function()
		return pane:pane_id()
	end)
	if ok and id then
		return tostring(id)
	end

	return "unknown"
end

local function pane_tab(pane)
	local ok, tab = pcall(function()
		return pane:tab()
	end)
	if ok then
		return tab
	end

	return nil
end

local function tab_id(tab)
	if not tab then
		return nil
	end

	local ok, id = pcall(function()
		return tab:tab_id()
	end)
	if ok and id then
		return tostring(id)
	end

	return nil
end

local function project_panes(session)
	local editor = runtime.pane(session.id, "editor")
	local explorer = runtime.pane(session.id, "explorer")
	if not editor or not explorer then
		return nil, nil, nil, "pane lookup failed: project editor/explorer panes are unavailable"
	end

	local editor_tab = pane_tab(editor)
	local explorer_tab = pane_tab(explorer)
	local editor_tab_id = tab_id(editor_tab)
	local explorer_tab_id = tab_id(explorer_tab)
	if editor_tab_id and explorer_tab_id and editor_tab_id ~= explorer_tab_id then
		return nil,
			nil,
			nil,
			string.format(
				"same-tab check failed: editor pane %s tab %s explorer pane %s tab %s",
				pane_id(editor),
				editor_tab_id,
				pane_id(explorer),
				explorer_tab_id
			)
	end

	return editor, explorer, editor_tab or explorer_tab, nil
end

local function active_tab(window)
	local ok, tab = pcall(function()
		return window:active_tab()
	end)
	if ok then
		return tab
	end

	return nil
end

local function tab_fallback_panes(window)
	local tab = active_tab(window)
	if not tab then
		return nil, nil, nil, nil, "tab fallback failed: active tab is unavailable"
	end

	local ok, panes = pcall(function()
		return tab:panes_with_info()
	end)
	if not ok or type(panes) ~= "table" or #panes < 2 then
		return nil, nil, nil, nil, "tab fallback failed: active tab does not have at least two panes"
	end

	table.sort(panes, function(a, b)
		if a.left == b.left then
			return a.top < b.top
		end
		return a.left < b.left
	end)

	local explorer_info = panes[1]
	local editor_info = panes[#panes]
	if not explorer_info.pane or not editor_info.pane then
		return nil, nil, nil, nil, "tab fallback failed: pane handles are unavailable"
	end

	return editor_info.pane, explorer_info.pane, tab, {
		id = "tab:" .. tostring(tab_id(tab) or "unknown"),
	}, nil
end

local function schedule(callback)
	if wezterm.time and type(wezterm.time.call_after) == "function" then
		wezterm.time.call_after(mutation_delay, callback)
		return
	end

	callback()
end

local function set_zoom(window, pane, target)
	local ok, err = pcall(function()
		window:perform_action(wezterm.action.SetPaneZoomState(target), pane)
	end)
	if ok then
		return true, nil
	end

	return false, "mutation failed: SetPaneZoomState(" .. tostring(target) .. ") failed: " .. tostring(err)
end

local function apply_zoom(window, action, editor, explorer)
	if action == "hide" then
		editor:activate()
		schedule(function()
			set_zoom(window, editor, true)
		end)
		return true
	end

	local ok = set_zoom(window, editor, false)
	if not ok then
		return false
	end

	schedule(function()
		explorer:activate()
	end)
	return true
end

function M.dispatch(window, pane, action)
	if action ~= "hide" and action ~= "reveal" then
		return false
	end

	local session = active_session(window, pane)
	local editor, explorer
	if type(session) == "table" then
		editor, explorer = project_panes(session)
	end

	if not editor then
		editor, explorer = tab_fallback_panes(window)
		if not editor then
			return false
		end
	end

	if action == "hide" then
		apply_zoom(window, action, editor, explorer)
		return true
	end

	apply_zoom(window, action, editor, explorer)
	return true
end

local function visibility_key(key, action)
	return {
		key = key,
		mods = "SHIFT",
		action = wezterm.action_callback(function(window, pane)
			M.dispatch(window, pane, action)
		end),
	}
end

function M.apply_to_config(config)
	config.keys = config.keys or {}

	table.insert(config.keys, visibility_key("H", "hide"))
	table.insert(config.keys, visibility_key("R", "reveal"))
end

return M
