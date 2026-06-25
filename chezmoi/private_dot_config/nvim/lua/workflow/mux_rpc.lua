local M = {}

local directions = {
	left = true,
	right = true,
	up = true,
	down = true,
}

local function smart_mux()
	local ok, mux = pcall(require, "smart-splits.mux")
	if not ok then
		return nil, "smart-splits.mux is unavailable"
	end

	return mux, nil
end

local function focus(direction)
	if not directions[direction] then
		return false, "unknown focus direction"
	end

	local mux, err = smart_mux()
	if not mux then
		return false, err
	end

	return mux.move_pane(direction, false), nil
end

local function resize(direction, amount)
	if not directions[direction] then
		return false, "unknown resize direction"
	end

	local mux, err = smart_mux()
	if not mux then
		return false, err
	end

	return mux.resize_pane(direction, amount), nil
end

local layouts = {
	hide = function()
		focus("right")
		return resize("left", 80)
	end,
	reveal = function()
		return focus("left")
	end,
	narrow = function()
		focus("right")
		return resize("left", 8)
	end,
	wide = function()
		focus("left")
		return resize("right", 8)
	end,
}

function M.open(path)
	if type(path) ~= "string" or path == "" then
		return false, "missing open path"
	end

	vim.cmd.edit(vim.fn.fnameescape(path))
	focus("right")
	return true, nil
end

function M.layout(kind)
	local apply = layouts[kind]
	if not apply then
		return false, "unknown explorer layout kind"
	end

	return apply()
end

function M.dispatch(op, value)
	local ok, err
	if op == "open" then
		ok, err = M.open(value)
	elseif op == "layout" then
		ok, err = M.layout(value)
	else
		ok, err = false, "unknown mux RPC operation"
	end

	if not ok then
		vim.notify(err, vim.log.levels.ERROR, { title = "Xplr RPC" })
	end

	return ok
end

_G.TermXplrMuxRpc = M.dispatch

return M
