-- lua/git/hunks.lua

local M = {}

function M.setup()
	require("gitsigns").setup({
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(lhs, rhs, desc, opts)
				opts = opts or {}
				vim.keymap.set("n", lhs, rhs, {
					buffer = bufnr,
					desc = desc,
					expr = opts.expr,
				})
			end

			map("]h", function()
				if vim.wo.diff then
					return "]h"
				end

				vim.schedule(gitsigns.next_hunk)
				return "<ignore>"
			end, "Next git hunk", { expr = true })

			map("[h", function()
				if vim.wo.diff then
					return "[h"
				end

				vim.schedule(gitsigns.prev_hunk)
				return "<ignore>"
			end, "Previous git hunk", { expr = true })

			map("<leader>ghp", gitsigns.preview_hunk, "Preview git hunk")
			map("<leader>ghs", gitsigns.stage_hunk, "Stage git hunk")
			map("<leader>ghr", gitsigns.reset_hunk, "Reset git hunk")
		end,
	})
end

return M
