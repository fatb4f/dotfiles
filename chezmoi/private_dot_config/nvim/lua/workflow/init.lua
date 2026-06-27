-- lua/workflow/init.lua

require("workflow.smart_splits")
require("workflow.mux_rpc")
require("workflow.project_home").setup()
require("workflow.project_buffer").setup()

return {}
