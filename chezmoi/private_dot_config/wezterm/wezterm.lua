local wezterm = require("wezterm") ---@type Wezterm
local shell = require("modules.shell")
local act = wezterm.action

local config = wezterm.config_builder() ---@type Config

config.enable_wayland = true
config.default_prog = shell.login_args()
config.default_workspace = wezterm.home_dir

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.window_close_confirmation = "NeverPrompt"

config.scrollback_lines = 10000
config.keys = config.keys or {}
table.insert(config.keys, {
	key = "Enter",
	mods = "SHIFT",
	action = act.SendKey({ key = "j", mods = "CTRL" }),
})

require("modules.smart_splits").apply_to_config(config)
require("modules.workspaces.sessionizer").apply_to_config(config)
require("modules.workspaces.project_tree_visibility").apply_to_config(config)
require("modules.workspaces.events").setup()
require("modules.workspaces.palette").setup()
require("modules.scrollback").apply_to_config(config)
require("modules.tinty").apply_to_config(config)
require("modules.tabline").apply_to_config(config)

return config
