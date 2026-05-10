local model = require("generated.model")
local binds = require("generated.binds")

local mainMod = model.mod or "SUPER"
local commands = model.commands or {}

local function bind_chord(bind)
	if bind.chord ~= nil then
		return bind.chord
	end

	local mod = bind.mod

	if mod == "main" then
		mod = mainMod
	end

	if mod == nil or mod == "" then
		return bind.key
	end

	return mod .. " + " .. bind.key
end

local function command_for(bind)
	local command = bind.command
	return commands[command] or command
end

for _, bind in ipairs(binds) do
	if bind.action == "exec" then
		hl.bind(bind_chord(bind), hl.dsp.exec_cmd(command_for(bind)))
	elseif bind.action == "close" then
		hl.bind(bind_chord(bind), hl.dsp.window.close())
	elseif bind.action == "maximize" then
		hl.bind(
			bind_chord(bind),
			hl.dsp.window.fullscreen({
				mode = "maximized",
				action = "toggle",
			})
		)
	end
end

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
