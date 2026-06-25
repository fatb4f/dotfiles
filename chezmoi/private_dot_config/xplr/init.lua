local xplr = xplr

local project_root = os.getenv("TERM_PROJECT_ROOT")

local function rpc_binding(help, op, field, value)
	return {
		help = help,
		messages = {
			{
				BashExecSilently0 = string.format(
					[===[
        payload=$(
          TERM_XPLR_OP=%q TERM_XPLR_FIELD=%q TERM_XPLR_VALUE=%q python3 - <<'PY'
import json
import os

op = os.environ["TERM_XPLR_OP"]
field = os.environ["TERM_XPLR_FIELD"]
value = os.environ["TERM_XPLR_VALUE"]
print(json.dumps({"op": op, field: value}, separators=(",", ":")))
PY
        ) || exit
        printf '\033]1337;SetUserVar=TERM_XPLR_RPC=%%s\a' "$(printf '%%s' "$payload" | base64 | tr -d '\n')"
      ]===],
					op,
					field,
					value
				),
			},
		},
	}
end

xplr.config.general.read_only = true
xplr.config.general.show_hidden = false
xplr.config.general.enable_mouse = false
xplr.config.general.hide_remaps_in_help_menu = true

xplr.config.general.table.header.cols = {
	{ format = " project tree" },
}
xplr.config.general.table.row.cols = {
	{ format = "builtin.fmt_general_table_row_cols_1" },
}
xplr.config.general.table.col_widths = {
	{ Percentage = 100 },
}

xplr.config.modes.builtin.default.key_bindings.on_key["enter"] = {
	help = "open",
	messages = {
		{
			BashExecSilently0 = [===[
        if [ -d "${XPLR_FOCUS_PATH:?}" ]; then
          "$XPLR" -m Enter
        else
          payload=$(
            TERM_XPLR_PATH="${XPLR_FOCUS_PATH:?}" python3 - <<'PY'
import json
import os

print(json.dumps({"op": "open", "path": os.environ["TERM_XPLR_PATH"]}, separators=(",", ":")))
PY
          ) || exit
          printf '\033]1337;SetUserVar=TERM_XPLR_RPC=%s\a' "$(printf '%s' "$payload" | base64 | tr -d '\n')"
        fi
      ]===],
		},
	},
}

xplr.config.modes.builtin.default.key_bindings.on_key["right"] =
	xplr.config.modes.builtin.default.key_bindings.on_key["enter"]
xplr.config.modes.builtin.default.key_bindings.on_key["H"] = rpc_binding("hide tree", "layout", "kind", "hide")
xplr.config.modes.builtin.default.key_bindings.on_key["R"] = rpc_binding("reveal tree", "layout", "kind", "reveal")
xplr.config.modes.builtin.default.key_bindings.on_key["N"] = rpc_binding("narrow tree", "layout", "kind", "narrow")
xplr.config.modes.builtin.default.key_bindings.on_key["W"] = rpc_binding("widen tree", "layout", "kind", "wide")

local on_load = {}
if project_root and project_root:sub(1, 1) == "/" then
	table.insert(on_load, { SetVroot = project_root })
	table.insert(on_load, { ChangeDirectory = project_root })
end

return {
	on_load = on_load,
}
