local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.enable_wayland = true
config.default_prog = { os.getenv("SHELL") or "/bin/bash", "-l" }

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.window_close_confirmation = "NeverPrompt"

config.scrollback_lines = 10000

require("modules.smart_splits").apply_to_config(config)
require("modules.workspaces").apply_to_config(config)
require("modules.scrollback").apply_to_config(config)
require("modules.status").apply_to_config(config)

return config
