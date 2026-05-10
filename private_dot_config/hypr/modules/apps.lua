local model = require("generated.model")

_G.HYPR_APPS = model.apps or {}
_G.HYPR_MOD = model.mod or "SUPER"

return {
  apps = _G.HYPR_APPS,
  mod = _G.HYPR_MOD,
}
