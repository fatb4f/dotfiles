local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
	local path = wezterm.config_dir .. "/colors/tinty.lua"
	local ok, colors = pcall(dofile, path)
	if ok and type(colors) == "table" then
		config.colors = colors
	end
end

return M
