local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

wezterm.on("open-scrollback-in-nvim", function(window, pane)
  local dims = pane:get_dimensions()
  local text = pane:get_lines_as_text(dims.scrollback_rows)

  local name = os.tmpname() .. ".wezterm-scrollback.txt"
  local file = assert(io.open(name, "w+"))

  file:write(text)
  file:flush()
  file:close()

  window:perform_action(
    act.SpawnCommandInNewWindow({
      args = {
        os.getenv("EDITOR") or "nvim",
        name,
        "-c",
        "setlocal buftype=nofile bufhidden=wipe noswapfile",
        "-c",
        "setfiletype wezterm-scrollback",
      },
    }),
    pane
  )
end)

function M.apply_to_config(config)
  config.keys = config.keys or {}

  table.insert(config.keys, {
    key = "E",
    mods = "CTRL|SHIFT",
    action = act.EmitEvent("open-scrollback-in-nvim"),
  })
end

return M
