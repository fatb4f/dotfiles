-- lua/lang/process.lua

local M = {}

function M.bunx(...)
	local cmd = { "bunx", "--bun", "--no-install" }
	vim.list_extend(cmd, { ... })
	return cmd
end

function M.bun_run(script, ...)
	local cmd = { "bun", "run", "--silent", script }
	vim.list_extend(cmd, { ... })
	return cmd
end

return M
