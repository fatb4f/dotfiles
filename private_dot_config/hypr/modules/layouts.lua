local model = require("generated.model")
local layout = model.layout or {}

hl.config({
  general = {
    layout = layout.default or "master",
  },

  master = {
    new_status = "master",
    mfact = 0.70,
  },

  dwindle = {
    preserve_split = true,
  },

  scrolling = {
    fullscreen_on_one_column = true,
    column_width = 0.67,
    follow_focus = true,
  },
})
