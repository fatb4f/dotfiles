-- lua/nav/pick.lua

local M = {}

local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { desc = desc })
end

local function select_command()
	local commands = vim.tbl_keys(vim.api.nvim_get_commands({}))
	table.sort(commands)

	vim.ui.select(commands, { prompt = "Commands" }, function(command)
		if command then
			vim.cmd(command)
		end
	end)
end

local function select_keymap()
	local keymaps = {}

	for _, mode in ipairs({ "n", "x", "o", "i", "s", "t" }) do
		for _, keymap in ipairs(vim.api.nvim_get_keymap(mode)) do
			if keymap.desc then
				table.insert(keymaps, {
					mode = mode,
					lhs = keymap.lhs,
					desc = keymap.desc,
				})
			end
		end
	end

	table.sort(keymaps, function(a, b)
		return (a.mode .. a.lhs) < (b.mode .. b.lhs)
	end)

	vim.ui.select(keymaps, {
		prompt = "Keymaps",
		format_item = function(item)
			return string.format("%s  %s  %s", item.mode, item.lhs, item.desc)
		end,
	}, function(item)
		if not item then
			return
		end

		local keys = vim.api.nvim_replace_termcodes(item.lhs, true, false, true)
		vim.api.nvim_feedkeys(keys, "m", false)
	end)
end

function M.setup()
	local pick = require("mini.pick")

	pick.setup()
	vim.ui.select = pick.ui_select

	map("<leader>pf", pick.builtin.files, "Pick files")
	map("<leader>pg", pick.builtin.grep_live, "Pick grep")
	map("<leader>pb", pick.builtin.buffers, "Pick buffers")
	map("<leader>ph", pick.builtin.help, "Pick help")
	map("<leader>pc", select_command, "Pick commands")
	map("<leader>pk", select_keymap, "Pick keymaps")
end

return M
