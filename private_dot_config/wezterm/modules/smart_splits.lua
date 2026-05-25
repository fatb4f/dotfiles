local wezterm = require("wezterm")

local M = {}

local direction_keys = {
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
}

-- Contract:
--   Neovim emits pane user var IS_NVIM=true while it owns the pane.
--   Ctrl+h/j/k/l moves across Neovim splits or WezTerm panes.
--   Alt+h/j/k/l resizes Neovim splits or WezTerm panes by 3 cells.
local function is_nvim(pane)
  return pane:get_user_vars().IS_NVIM == "true"
end

local function split_nav(kind, key)
  return {
    key = key,
    mods = kind == "resize" and "ALT" or "CTRL",
    action = wezterm.action_callback(function(window, pane)
      if is_nvim(pane) then
        window:perform_action({
          SendKey = {
            key = key,
            mods = kind == "resize" and "ALT" or "CTRL",
          },
        }, pane)
        return
      end

      if kind == "resize" then
        window:perform_action({
          AdjustPaneSize = { direction_keys[key], 3 },
        }, pane)
      else
        window:perform_action({
          ActivatePaneDirection = direction_keys[key],
        }, pane)
      end
    end),
  }
end

function M.apply_to_config(config)
  config.keys = config.keys or {}

  table.insert(config.keys, split_nav("move", "h"))
  table.insert(config.keys, split_nav("move", "j"))
  table.insert(config.keys, split_nav("move", "k"))
  table.insert(config.keys, split_nav("move", "l"))

  table.insert(config.keys, split_nav("resize", "h"))
  table.insert(config.keys, split_nav("resize", "j"))
  table.insert(config.keys, split_nav("resize", "k"))
  table.insert(config.keys, split_nav("resize", "l"))
end

return M
