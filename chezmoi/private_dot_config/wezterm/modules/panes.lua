local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function resize_by_percentage(direction, percentage)
	return wezterm.action_callback(function(window, pane)
		local dimensions = pane:get_dimensions()
		local horizontal = direction == "Left" or direction == "Right"
		local dimension = horizontal and dimensions.cols or dimensions.viewport_rows
		local cells = math.max(1, math.floor(dimension * percentage / 100 + 0.5))

		window:perform_action(act.AdjustPaneSize({ direction, cells }), pane)
	end)
end

local function resize_key_table(direction)
	local keys = {}

	for digit = 1, 9 do
		table.insert(keys, {
			key = tostring(digit),
			action = resize_by_percentage(direction, digit * 10),
		})
	end

	return keys
end

function M.apply_to_config(config)
	config.keys = config.keys or {}
	config.key_tables = config.key_tables or {}

	table.insert(config.keys, {
		key = "s",
		mods = "CTRL|SHIFT",
		action = act.SplitPane({ direction = "Right" }),
	})
	table.insert(config.keys, {
		key = "d",
		mods = "CTRL|SHIFT",
		action = act.SplitPane({ direction = "Down" }),
	})
	table.insert(config.keys, {
		key = "z",
		mods = "CTRL|SHIFT",
		action = act.TogglePaneZoomState,
	})
	table.insert(config.keys, {
		key = "w",
		mods = "CTRL|SHIFT",
		action = act.CloseCurrentPane({ confirm = true }),
	})
	table.insert(config.keys, {
		key = "o",
		mods = "CTRL|SHIFT",
		action = act.PaneSelect({
			mode = "Activate",
			show_pane_ids = true,
		}),
	})

	for key, direction in pairs(direction_keys) do
		local table_name = "resize_pane_" .. direction:lower()
		config.key_tables[table_name] = resize_key_table(direction)

		table.insert(config.keys, {
			key = key,
			mods = "CTRL|SHIFT",
			action = act.ActivatePaneDirection(direction),
		})
		table.insert(config.keys, {
			key = key,
			mods = "CTRL|SHIFT|ALT",
			action = act.ActivateKeyTable({
				name = table_name,
				one_shot = true,
				timeout_milliseconds = 2000,
				until_unknown = true,
			}),
		})
	end
end

return M
