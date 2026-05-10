local rules = require("generated.rules")

for _, rule in ipairs(rules.windows or {}) do
  hl.window_rule(rule)
end

for _, rule in ipairs(rules.layers or {}) do
  hl.layer_rule(rule)
end
