-- lua/nav/trouble.lua

local M = {}

local function map(lhs, command, desc)
	vim.keymap.set("n", lhs, command, { desc = desc })
end

function M.setup()
	require("trouble").setup()

	map("<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics")
	map("<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer diagnostics")
	map("<leader>xq", "<cmd>Trouble qflist toggle<cr>", "Quickfix")
	map("<leader>xl", "<cmd>Trouble loclist toggle<cr>", "Loclist")
	map("<leader>xr", "<cmd>Trouble lsp toggle focus=false<cr>", "LSP references")
	map("<leader>xs", "<cmd>Trouble symbols toggle<cr>", "Symbols")
end

return M
