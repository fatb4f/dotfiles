version = "1.1.0"

local xplr = xplr

local project_root = os.getenv("TERM_PROJECT_ROOT")

local function sh_quote(value)
	return "'" .. tostring(value):gsub("'", "'\"'\"'") .. "'"
end

local function rpc_binding(help, op, field, value)
	return {
		help = help,
		messages = {
			{
				BashExec0 = string.format(
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
        printf '\033]1337;SetUserVar=TERM_XPLR_RPC=%%s\a' "$payload" > /dev/tty
      ]===],
					op,
					field,
					value
				),
			},
		},
	}
end

xplr.config.general.read_only = false
xplr.config.general.show_hidden = false
xplr.config.general.enable_mouse = false
xplr.config.general.hide_remaps_in_help_menu = true
xplr.config.general.initial_layout = "compact"

xplr.config.layouts.builtin.compact = "Table"

xplr.config.general.table.header.cols = {
	{ format = " project tree" },
}
xplr.config.general.table.row.cols = {
	{ format = "builtin.fmt_general_table_row_cols_1" },
}
xplr.config.general.table.col_widths = {
	{ Percentage = 100 },
}

local function is_dir(node)
	return node and (node.is_dir or (node.symlink and node.symlink.is_dir))
end

local function direct_open_script(path)
	return table.concat({
		"set -eu",
		"printf 'xplr-open %s\\n' " .. sh_quote(path) .. " >> /tmp/xplr-open.trace",
		"path=$(realpath --canonicalize-existing " .. sh_quote(path) .. ")",
		"root=$(realpath --canonicalize-existing \"${TERM_PROJECT_ROOT:?}\")",
		"case \"$path\" in \"$root\"|\"$root\"/*) ;; *) exit 23 ;; esac",
		"socket=${TERM_NVIM_SOCKET:?}",
		"test -S \"$socket\"",
		"expr=$(TERM_XPLR_PATH=\"$path\" python3 - <<'PY'",
		"import os",
		"print('v:lua.TermXplrMuxRpc(\"open\", %r)' % os.environ['TERM_XPLR_PATH'])",
		"PY",
		")",
		"set +e",
		"${TERM_EDITOR:-nvim} --server \"$socket\" --remote-expr \"$expr\" >/tmp/xplr-open.out 2>/tmp/xplr-open.err",
		"status=$?",
		"set -e",
		"result=$(cat /tmp/xplr-open.out /tmp/xplr-open.err 2>/dev/null | tr -d '\\r' | tail -n 1)",
		"case \"$result\" in true|1|v:true) exit 0 ;; esac",
		"exit \"$status\"",
	}, "\n")
end

xplr.fn.custom.project_tree = xplr.fn.custom.project_tree or {}
xplr.fn.custom.project_tree.open = function(app)
	local node = app.focused_node
	if not node then
		return
	end

	if is_dir(node) then
		return {
			"Enter",
		}
	end

	return {
		{
			BashExec0 = direct_open_script(node.absolute_path),
		},
	}
end

local project_tree_open_binding = {
	help = "enter/open",
	messages = {
		{
			CallLuaSilently = "custom.project_tree.open",
		},
	},
}

xplr.config.modes.builtin.default.key_bindings.on_key["h"] =
	xplr.config.modes.builtin.default.key_bindings.on_key["left"]
xplr.config.modes.builtin.default.key_bindings.on_key["j"] =
	xplr.config.modes.builtin.default.key_bindings.on_key["down"]
xplr.config.modes.builtin.default.key_bindings.on_key["k"] =
	xplr.config.modes.builtin.default.key_bindings.on_key["up"]
xplr.config.modes.builtin.default.key_bindings.on_key["l"] = project_tree_open_binding
xplr.config.modes.builtin.default.key_bindings.on_key["enter"] = project_tree_open_binding
xplr.config.modes.builtin.default.key_bindings.on_key["right"] = project_tree_open_binding
xplr.config.modes.builtin.default.key_bindings.on_key[":"] = nil
xplr.config.modes.builtin.default.key_bindings.on_key["c"] = nil
xplr.config.modes.builtin.default.key_bindings.on_key["d"] = nil
xplr.config.modes.builtin.default.key_bindings.on_key["m"] = nil
xplr.config.modes.builtin.default.key_bindings.on_key["r"] = nil
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
