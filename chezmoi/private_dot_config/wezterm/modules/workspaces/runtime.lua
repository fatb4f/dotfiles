local wezterm = require("wezterm")

local M = {}

local function state()
	wezterm.GLOBAL.term_workspaces = wezterm.GLOBAL.term_workspaces or {
		sessions = {},
		panes = {},
	}
	return wezterm.GLOBAL.term_workspaces
end

function M.remember_session(session)
	local current = state()
	current.sessions[session.workspace] = {
		id = session.id,
		label = session.label,
		root = session.root,
		cwd = session.cwd,
		workspace = session.workspace,
		editor = session.editor,
		env = session.env,
	}
end

function M.session_for_workspace(workspace)
	return state().sessions[workspace]
end

function M.remember_pane(project_id, role, pane)
	local current = state()
	current.panes[project_id] = current.panes[project_id] or {}
	current.panes[project_id][role] = pane:pane_id()
end

function M.pane(project_id, role)
	local project_panes = state().panes[project_id]
	if not project_panes then
		return nil
	end

	local pane_id = project_panes[role]
	if not pane_id then
		return nil
	end

	local pane = wezterm.mux.get_pane(pane_id)
	if not pane then
		project_panes[role] = nil
	end

	return pane
end

return M
