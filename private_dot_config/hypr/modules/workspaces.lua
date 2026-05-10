local workspaces = require("generated.workspaces")

for _, rule in ipairs(workspaces) do
  hl.workspace_rule(rule)
end
