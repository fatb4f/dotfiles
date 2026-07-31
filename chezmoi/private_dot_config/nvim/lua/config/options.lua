vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.relativenumber = true
opt.timeoutlen = 500
opt.updatetime = 250
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 4
		vim.bo.tabstop = 4
	end,
})

local function run_uv(executable, args)
	local root = vim.fs.root(0, { "pyproject.toml", "uv.lock" }) or vim.uv.cwd()
	local command = vim.list_extend({ "uv", "run", "--directory", root, executable }, args or {})
	vim.system(command, { cwd = root, text = true }, function(result)
		vim.schedule(function()
			vim.fn.setqflist({}, " ", {
				title = table.concat(command, " "),
				lines = vim.split(
					(result.stdout or "") .. (result.stderr or ""),
					"\n",
					{ plain = true, trimempty = true }
				),
			})
			vim.cmd("copen")
			vim.notify(table.concat(command, " ") .. " exited with " .. result.code)
		end)
	end)
end

vim.api.nvim_create_user_command("UvPytest", function()
	run_uv("pytest")
end, { desc = "Run pytest with the project uv environment" })
vim.api.nvim_create_user_command("UvTyCheck", function()
	run_uv("ty", { "check" })
end, { desc = "Run ty check with the project uv environment" })
