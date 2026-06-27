local M = {}

local function project_id()
	return vim.env.TERM_PROJECT_ID or "project"
end

local function project_root()
	return vim.env.TERM_PROJECT_ROOT or vim.loop.cwd()
end

function M.find()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.b[bufnr].term_project_home == true then
			return bufnr
		end
	end

	return nil
end

function M.ensure()
	local existing = M.find()
	if existing then
		return existing
	end

	local bufnr = vim.api.nvim_create_buf(false, true)

	vim.b[bufnr].term_project_home = true
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "hide"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].buflisted = false
	vim.bo[bufnr].modifiable = true

	vim.api.nvim_buf_set_name(bufnr, "project://" .. project_id())

	local lines = {
		"# " .. project_id(),
		"",
		"root: " .. project_root(),
		"",
		"Open files from xplr.",
		"",
		"Commands:",
		"  :Bd      close current buffer",
		"  :Bd!     force close current buffer",
		"  :qa!     exit project editor",
	}

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.bo[bufnr].modifiable = false

	return bufnr
end

function M.show()
	local bufnr = M.ensure()
	vim.api.nvim_set_current_buf(bufnr)
end

function M.setup()
	if vim.env.TERM_PROJECT_ID and vim.env.TERM_NVIM_SOCKET then
		vim.schedule(function()
			if vim.api.nvim_buf_get_name(0) == "" then
				M.show()
			end
		end)
	end
end

return M
