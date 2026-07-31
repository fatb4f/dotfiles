-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
	end,
})

local quickfix_ui = vim.api.nvim_create_augroup("quickfix_ui", { clear = true })

local function resize_list(buf)
	if vim.bo[buf].filetype ~= "qf" then
		return
	end

	local height = math.min(math.max(vim.api.nvim_buf_line_count(buf), 3), 12)
	vim.cmd("resize " .. height)
end

vim.api.nvim_create_autocmd("FileType", {
	group = quickfix_ui,
	pattern = "qf",
	callback = function(args)
		vim.opt_local.wrap = false
		vim.opt_local.cursorline = true
		vim.opt_local.signcolumn = "no"
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.winfixheight = true

		local function close_list()
			if vim.fn.win_gettype() == "loclist" then
				vim.cmd("lclose")
			else
				vim.cmd("cclose")
			end
		end

		for _, lhs in ipairs({ "q", "<Esc>" }) do
			vim.keymap.set("n", lhs, close_list, {
				buffer = args.buf,
				silent = true,
				desc = "Close list",
			})
		end

		resize_list(args.buf)
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = quickfix_ui,
	callback = function(args)
		resize_list(args.buf)
	end,
})
