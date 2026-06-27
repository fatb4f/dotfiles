local M = {}

local project_home = require("workflow.project_home")

local augroup = vim.api.nvim_create_augroup("ProjectBuffer", { clear = true })

local function in_project_mode()
	return vim.env.TERM_PROJECT_ID ~= nil and vim.env.TERM_NVIM_SOCKET ~= nil
end

local function is_project_home(bufnr)
	return vim.b[bufnr].term_project_home == true
end

local function show_home_after_close(closed_bufnr)
	if not in_project_mode() then
		return
	end

	local closed_home = is_project_home(closed_bufnr)
	if not closed_home and closed_bufnr ~= vim.api.nvim_get_current_buf() then
		return
	end

	vim.schedule(function()
		if not in_project_mode() or vim.v.dying ~= 0 then
			return
		end

		project_home.show()
	end)
end

local function show_home_if_empty()
	if not in_project_mode() then
		return
	end

	vim.schedule(function()
		if not in_project_mode() or vim.v.dying ~= 0 then
			return
		end

		if vim.api.nvim_buf_get_name(0) == "" then
			project_home.show()
		end
	end)
end

function M.close(opts)
	local bang = opts and opts.bang
	local bufnr = vim.api.nvim_get_current_buf()

	if is_project_home(bufnr) then
		project_home.show()
		return
	end

	vim.cmd((bang and "bdelete! " or "bdelete ") .. bufnr)
end

function M.setup()
	if not in_project_mode() then
		return
	end

	vim.api.nvim_create_user_command("Bd", function(opts)
		M.close(opts)
	end, {
		bang = true,
		desc = "Close current project buffer",
	})

	vim.api.nvim_create_user_command("ProjectBufferClose", function(opts)
		M.close(opts)
	end, {
		bang = true,
		desc = "Close current project buffer",
	})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = augroup,
		callback = function(args)
			show_home_after_close(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		callback = show_home_if_empty,
	})
end

return M
