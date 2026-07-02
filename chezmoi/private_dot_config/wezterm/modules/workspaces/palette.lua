local wezterm = require("wezterm")

local M = {}

local function visibility_entry(label, action)
	return {
		brief = label,
		doc = "Toggle the project tree through WezTerm tab visibility",
		action = wezterm.action.EmitEvent("term-project-tree-" .. action),
	}
end

function M.setup()
	wezterm.on("augment-command-palette", function()
		return {
			{
				brief = "Launch project IDE",
				doc = "Launch or focus socket-backed Neovim and the project Xplr pane",
				action = wezterm.action.EmitEvent("term-ide-launch"),
			},
			visibility_entry("Hide project tree", "hide"),
			visibility_entry("Reveal project tree", "reveal"),
		}
	end)
end

return M
