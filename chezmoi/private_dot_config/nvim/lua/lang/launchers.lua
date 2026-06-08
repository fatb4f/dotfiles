-- lua/lang/launchers.lua

local M = {}

function M.bunx(package_name, executable, ...)
  local cmd = { "bunx", "--bun", "--package", package_name, executable }
  vim.list_extend(cmd, { ... })
  return cmd
end

return M
