local monitors = require("generated.monitors")

for _, monitor in ipairs(monitors) do
  hl.monitor({
    output = monitor.output,
    mode = monitor.mode or "preferred",
    position = monitor.position or "auto",
    scale = monitor.scale or 1,
  })
end
