local wezterm = require("wezterm")

local M = {}

function M.setup()
	wezterm.on("augment-command-palette", function()
		return {
			{
				brief = "Launch project IDE",
				doc = "Launch or focus socket-backed Neovim for the active project",
				action = wezterm.action.EmitEvent("term-ide-launch"),
			},
			{
				brief = "Launch project MCP",
				doc = "Launch the project git MCP adapter from the active project contract",
				action = wezterm.action.EmitEvent("term-project-command-mcp"),
			},
		}
	end)
end

return M
