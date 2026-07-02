local M = {}

local preview_active = false
local preview_delta = 64
local hide_delta = 80
local preview_window
local preview_directory_buffer
local preview_namespace = vim.api.nvim_create_namespace("xplr-preview")
local directory_preview_max_depth = 2
local directory_preview_max_entries = 200

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

		ok, err = resize("left", hide_delta)
		if not ok then
			return false, err
		end

		return true, nil
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

		ok, err = resize("right", 8)
		return ok, err
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

local function ensure_preview_highlights()
	pcall(vim.api.nvim_set_hl, 0, "XplrPreviewTreeGlyph", { default = true, link = "NonText" })
	pcall(vim.api.nvim_set_hl, 0, "XplrPreviewDirectory", { default = true, link = "Directory" })
end

local function sorted_directory_entries(path)
	local ok, iter = pcall(vim.fs.dir, path)
	if not ok or not iter then
		return nil
	end

	local entries = {}
	for name, type in iter do
		table.insert(entries, { name = name, type = type })
	end

	table.sort(entries, function(left, right)
		if left.type ~= right.type then
			return left.type == "directory"
		end

		return left.name:lower() < right.name:lower()
	end)

	return entries
end

local function add_tree_line(lines, highlights, line, glyph_end, directory_start)
	table.insert(lines, line)
	local row = #lines - 1
	table.insert(highlights, {
		group = "XplrPreviewTreeGlyph",
		row = row,
		from = 0,
		to = glyph_end,
	})

	if directory_start then
		table.insert(highlights, {
			group = "XplrPreviewDirectory",
			row = row,
			from = directory_start,
			to = #line,
		})
	end
end

local function append_directory_tree(path, prefix, depth, state)
	local entries = sorted_directory_entries(path)
	if not entries then
		add_tree_line(state.lines, state.highlights, prefix .. "`-- [unreadable]", #prefix + 4)
		return
	end

	for index, entry in ipairs(entries) do
		if state.count >= directory_preview_max_entries then
			add_tree_line(state.lines, state.highlights, prefix .. "`-- ... truncated", #prefix + 4)
			state.truncated = true
			return
		end

		state.count = state.count + 1
		local is_last = index == #entries
		local branch = is_last and "`-- " or "|-- "
		local suffix = entry.type == "directory" and "/" or ""
		local line = prefix .. branch .. entry.name .. suffix
		local directory_start = entry.type == "directory" and #prefix + #branch or nil
		add_tree_line(state.lines, state.highlights, line, #prefix + #branch, directory_start)

		if entry.type == "directory" and depth < directory_preview_max_depth and not state.truncated then
			local child_prefix = prefix .. (is_last and "    " or "|   ")
			append_directory_tree(path .. "/" .. entry.name, child_prefix, depth + 1, state)
		end
	end
end

local function directory_lines(path)
	local state = {
		count = 0,
		highlights = {},
		lines = { path, "", "." },
		truncated = false,
	}

	table.insert(state.highlights, {
		group = "XplrPreviewDirectory",
		row = 2,
		from = 0,
		to = 1,
	})
	append_directory_tree(path, "", 1, state)

	return state.lines, state.highlights
end

local function directory_buffer(path)
	if not preview_directory_buffer or not vim.api.nvim_buf_is_valid(preview_directory_buffer) then
		preview_directory_buffer = vim.api.nvim_create_buf(false, true)
		vim.bo[preview_directory_buffer].bufhidden = "hide"
		vim.bo[preview_directory_buffer].buftype = "nofile"
		vim.bo[preview_directory_buffer].swapfile = false
	end

	local lines, highlights = directory_lines(path)
	vim.bo[preview_directory_buffer].modifiable = true
	vim.api.nvim_buf_set_lines(preview_directory_buffer, 0, -1, false, lines)
	vim.bo[preview_directory_buffer].modifiable = false
	vim.bo[preview_directory_buffer].filetype = "xplr-preview"
	vim.bo[preview_directory_buffer].syntax = "xplr-preview"
	ensure_preview_highlights()
	vim.api.nvim_buf_clear_namespace(preview_directory_buffer, preview_namespace, 0, -1)
	for _, highlight in ipairs(highlights) do
		vim.api.nvim_buf_add_highlight(
			preview_directory_buffer,
			preview_namespace,
			highlight.group,
			highlight.row,
			highlight.from,
			highlight.to
		)
	end

	return preview_directory_buffer
end

local function activate_file_preview(bufnr, path)
	vim.bo[bufnr].buflisted = false

	local ok, filetype = pcall(function()
		return vim.filetype.match({ filename = path, buf = bufnr })
	end)
	if ok and type(filetype) == "string" and filetype ~= "" then
		vim.bo[bufnr].filetype = filetype
	end

	vim.api.nvim_buf_call(bufnr, function()
		pcall(vim.cmd, "silent! filetype detect")
		if vim.bo[bufnr].filetype ~= "" then
			vim.bo[bufnr].syntax = vim.bo[bufnr].filetype
		else
			pcall(vim.cmd, "silent! syntax enable")
		end
	end)
end

local function preview_buffer(path)
	if vim.fn.isdirectory(path) == 1 then
		return directory_buffer(path)
	end

	local bufnr = vim.fn.bufadd(path)
	vim.fn.bufload(bufnr)
	activate_file_preview(bufnr, path)
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
