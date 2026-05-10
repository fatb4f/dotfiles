local model = require("generated.model")
local binds = require("generated.binds")

local commands = model.commands or {}

local function command_for(bind)
	local command = bind.command

	if command == nil then
		return nil
	end

	return commands[command] or command
end

for _, bind in ipairs(binds) do
	if bind.action == "exec" then
		hl.bind(bind.chord, hl.dsp.exec_cmd(command_for(bind)))
	elseif bind.action == "close" then
		hl.bind(bind.chord, hl.dsp.window.close())
	elseif bind.action == "maximize" then
		hl.bind(
			bind.chord,
			hl.dsp.window.fullscreen({
				mode = "maximized",
				action = "toggle",
			})
		)
	end
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
