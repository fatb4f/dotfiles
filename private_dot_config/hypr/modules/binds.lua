local binds = require("generated.binds")

for _, bind in ipairs(binds) do
  if bind.action == "exec" then
    hl.bind(bind.chord, hl.dsp.exec_cmd(bind.command))
  elseif bind.action == "close" then
    hl.bind(bind.chord, hl.dsp.window.close())
  elseif bind.action == "maximize" then
    hl.bind(bind.chord, hl.dsp.window.fullscreen({
      mode = "maximized",
      action = "toggle",
    }))
  end
end

-- Mouse.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- UWSM-safe exit.
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
