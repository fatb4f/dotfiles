local M = {}

local preview_active = false
local preview_delta = 64
local hide_delta = 80
local preview_window
local preview_directory_buffer

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

local function remember_window()
	local ok, win = pcall(vim.api.nvim_get_current_win)
	return ok and win or nil
end

local function restore_window(win)
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
	end
end

local function ensure_preview_window()
	if preview_window and vim.api.nvim_win_is_valid(preview_window) then
		return preview_window
	end

	local previous = remember_window()
	vim.cmd("topleft vertical 50vnew")
	preview_window = vim.api.nvim_get_current_win()
	vim.wo[preview_window].winfixwidth = true
	vim.wo[preview_window].number = false
	vim.wo[preview_window].relativenumber = false
	vim.wo[preview_window].signcolumn = "no"
	restore_window(previous)

	return preview_window
end

local function directory_lines(path)
	local lines = { path, "" }
	local ok, entries = pcall(vim.fs.dir, path)
	if not ok or not entries then
		return { path, "", "Unable to read directory" }
	end

	local count = 0
	for name, type in entries do
		count = count + 1
		if count > 200 then
			table.insert(lines, "")
			table.insert(lines, "... truncated")
			break
		end

		local suffix = type == "directory" and "/" or ""
		table.insert(lines, suffix .. name)
	end

	return lines
end

local function directory_buffer(path)
	if not preview_directory_buffer or not vim.api.nvim_buf_is_valid(preview_directory_buffer) then
		preview_directory_buffer = vim.api.nvim_create_buf(false, true)
		vim.bo[preview_directory_buffer].bufhidden = "hide"
		vim.bo[preview_directory_buffer].buftype = "nofile"
		vim.bo[preview_directory_buffer].swapfile = false
	end

	vim.bo[preview_directory_buffer].modifiable = true
	vim.api.nvim_buf_set_lines(preview_directory_buffer, 0, -1, false, directory_lines(path))
	vim.bo[preview_directory_buffer].modifiable = false
	vim.bo[preview_directory_buffer].filetype = "xplr-preview"

	return preview_directory_buffer
end

local function preview_buffer(path)
	if vim.fn.isdirectory(path) == 1 then
		return directory_buffer(path)
	end

	local bufnr = vim.fn.bufadd(path)
	vim.fn.bufload(bufnr)
	vim.bo[bufnr].buflisted = false
	return bufnr
end

local function close_preview()
	if preview_window and vim.api.nvim_win_is_valid(preview_window) then
		vim.api.nvim_win_close(preview_window, true)
	end

	preview_window = nil
	preview_active = false
	focus("left")
	return true, nil
end

function M.preview(path)
	if path == "off" then
		return close_preview()
	end

	if type(path) ~= "string" or path == "" then
		return false, "missing preview path"
	end

	if vim.fn.filereadable(path) ~= 1 and vim.fn.isdirectory(path) ~= 1 then
		return false, "preview path is not readable"
	end

	local previous = remember_window()
	local win = ensure_preview_window()
	local bufnr = preview_buffer(path)
	vim.api.nvim_win_set_buf(win, bufnr)
	vim.api.nvim_win_set_cursor(win, { 1, 0 })

	preview_active = true
	restore_window(previous)
	focus("left")
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
	elseif op == "preview" then
		ok, err = M.preview(value)
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
