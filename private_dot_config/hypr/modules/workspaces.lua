local model = require("generated.model")
local workspaces = require("generated.workspaces")

local commands = model.commands or {}

local function resolve_rule(rule)
	local out = {}

	for key, value in pairs(rule) do
		out[key] = value
	end

	if out.on_created_empty ~= nil then
		out.on_created_empty = commands[out.on_created_empty] or out.on_created_empty
	end

	return out
end

for _, rule in ipairs(workspaces) do
	hl.workspace_rule(resolve_rule(rule))
end
