-- lua/lang/process.lua

local M = {}

function M.bunx(...)
	local cmd = { "bunx", "--bun", "--no-install" }
	vim.list_extend(cmd, { ... })
	return cmd
end

return M
