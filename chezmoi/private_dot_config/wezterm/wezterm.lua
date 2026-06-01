local wezterm = require("wezterm")
local shell = require("modules.shell")
local act = wezterm.action

local config = wezterm.config_builder()

config.enable_wayland = true
config.default_prog = shell.login_args()

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.window_close_confirmation = "NeverPrompt"

config.scrollback_lines = 10000
config.keys = config.keys or {}
table.insert(config.keys, {
  key = "Enter",
  mods = "SHIFT",
  action = act.SendString("\r"),
})

require("modules.smart_splits").apply_to_config(config)
require("modules.workspaces").apply_to_config(config)
require("modules.scrollback").apply_to_config(config)
require("modules.status").apply_to_config(config)

return config
