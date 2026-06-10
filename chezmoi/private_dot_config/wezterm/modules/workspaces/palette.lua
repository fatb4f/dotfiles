local wezterm = require("wezterm")

local M = {}

function M.setup()
	wezterm.on("augment-command-palette", function()
		return {
			{
				brief = "Launch project IDE",
				doc = "Launch or focus socket-backed Neovim and the project Xplr pane",
				action = wezterm.action.EmitEvent("term-ide-launch"),
			},
		}
	end)
end

return M
