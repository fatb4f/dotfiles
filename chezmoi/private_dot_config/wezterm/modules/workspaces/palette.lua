local wezterm = require("wezterm")

local M = {}

local function layout_entry(label, kind)
	return {
		brief = label,
		doc = "Route explorer layout through the validated xplr RPC boundary",
		action = wezterm.action.EmitEvent("term-xplr-layout-" .. kind),
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
			layout_entry("Hide project tree", "hide"),
			layout_entry("Reveal project tree", "reveal"),
			layout_entry("Narrow project tree", "narrow"),
			layout_entry("Widen project tree", "wide"),
		}
	end)
end

return M
