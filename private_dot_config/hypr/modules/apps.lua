local model = require("generated.model")

_G.HYPR_COMMANDS = model.commands or {}
_G.HYPR_MOD = model.mod or "SUPER"

return {
	commands = _G.HYPR_COMMANDS,
	mod = _G.HYPR_MOD,
}
