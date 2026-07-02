local M = {}

local preview_active = false
local preview_delta = 64
local hide_delta = 80

local directions = {
	left = true,
	right = true,
	up = true,
	down = true,
}

local function smart_mux()
	local ok, mux_api = pcall(require, "smart-splits.mux")
	if not ok then
		return nil, "smart-splits.mux API is unavailable"
	end

	local mux = mux_api.get()
	if not mux or not mux.is_in_session() then
		return nil, "smart-splits mux backend is unavailable"
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

	if not mux.next_pane(direction) then
		return false, "smart-splits mux focus failed: " .. direction
	end

	return true, nil
end

local function resize(direction, amount)
	if not directions[direction] then
		return false, "unknown resize direction"
	end

	local mux, err = smart_mux()
	if not mux then
		return false, err
	end

	if not mux.resize_pane(direction, amount) then
		return false, "smart-splits mux resize failed: " .. direction
	end

	return true, nil
end

local layouts = {
	hide = function()
		local ok, err = focus("right")
		if not ok then
			return false, err
		end

		return resize("left", hide_delta)
	end,
	reveal = function()
		return focus("left")
	end,
	narrow = function()
		local ok, err = focus("right")
		if not ok then
			return false, err
		end

		return resize("left", 8)
	end,
	wide = function()
		local ok, err = focus("left")
		if not ok then
			return false, err
		end

		return resize("right", 8)
	end,
	preview_on = function()
		if preview_active then
			return focus("left")
		end

		local ok, err = focus("left")
		if not ok then
			return false, err
		end

		ok, err = resize("right", preview_delta)
		if ok then
			preview_active = true
		end

		return ok, err
	end,
	preview_off = function()
		if not preview_active then
			return focus("left")
		end

		local ok, err = focus("right")
		if not ok then
			return false, err
		end

		ok, err = resize("left", preview_delta)
		if not ok then
			return false, err
		end

		preview_active = false
		return focus("left")
	end,
}

function M.open(path)
	if type(path) ~= "string" or path == "" then
		return false, "missing open path"
	end

	vim.cmd.edit(vim.fn.fnameescape(path))
	return focus("right")
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

-- selene: allow(global_usage)
_G.TermXplrMuxRpc = M.dispatch

return M
