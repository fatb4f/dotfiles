local model = require("generated.model")
local binds = require("generated.binds")

local commands = model.commands or {}
local mod = model.mod or "SUPER"
local unpack = table.unpack or unpack

local function die(message)
	error("hypr binds: " .. message, 2)
end

local function command_for(bind)
	local command = bind.command

	if command == nil then
		return nil
	end

	return commands[command] or command
end

local function chord_for(bind)
	if type(bind.chord) ~= "string" or bind.chord == "" then
		die("bind is missing chord")
	end

	return bind.chord:gsub("%$mod", mod)
end

local function resolve_path(root, path)
	if type(path) ~= "string" or path == "" then
		die("dispatcher must be a non-empty string")
	end

	local node = root

	for segment in path:gmatch("[^.]+") do
		if type(node) ~= "table" then
			die("dispatcher path is not traversable: " .. path)
		end

		node = node[segment]

		if node == nil then
			die("unknown dispatcher: " .. path)
		end
	end

	if type(node) ~= "function" then
		die("dispatcher is not callable: " .. path)
	end

	return node
end

local legacy = {
	exec = function(bind)
		return {
			chord = bind.chord,
			action = "dsp",
			dispatcher = "exec_cmd",
			command = bind.command,
			flags = bind.flags,
		}
	end,

	close = function(bind)
		return {
			chord = bind.chord,
			action = "dsp",
			dispatcher = "window.close",
			flags = bind.flags,
		}
	end,

	maximize = function(bind)
		return {
			chord = bind.chord,
			action = "dsp",
			dispatcher = "window.fullscreen",
			args = {
				{
					mode = "maximized",
					action = "toggle",
				},
			},
			flags = bind.flags,
		}
	end,
}

local function normalize(bind)
	if type(bind) ~= "table" then
		die("bind must be a table")
	end

	if bind.action == "dsp" then
		return bind
	end

	local adapter = legacy[bind.action]

	if adapter == nil then
		die("unsupported bind action: " .. tostring(bind.action))
	end

	return adapter(bind)
end

local function args_for(bind)
	if bind.command ~= nil then
		local command = command_for(bind)

		if command == nil or command == "" then
			die("empty command for chord: " .. tostring(bind.chord))
		end

		return { command }
	end

	return bind.args or {}
end

local function compile_dispatcher(bind)
	if bind.action ~= "dsp" then
		die("unsupported normalized bind action: " .. tostring(bind.action))
	end

	if bind.dispatcher == nil then
		die("bind is missing dispatcher for chord: " .. tostring(bind.chord))
	end

	local dispatcher = resolve_path(hl.dsp, bind.dispatcher)
	local args = args_for(bind)

	return dispatcher(unpack(args))
end

for _, raw_bind in ipairs(binds) do
	local bind = normalize(raw_bind)

	hl.bind(chord_for(bind), compile_dispatcher(bind), bind.flags)
end
