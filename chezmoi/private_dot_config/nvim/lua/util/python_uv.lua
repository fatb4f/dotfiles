local M = {}

local project_markers = { "pyproject.toml", "uv.lock" }

function M.root(bufnr)
	return vim.fs.root(bufnr or 0, project_markers) or vim.uv.cwd()
end

function M.command(root, executable, args)
	return vim.list_extend({ "uv", "run", "--frozen", "--no-sync", "--directory", root, executable }, args or {})
end

function M.start_lsp(executable)
	return function(dispatchers, config)
		local root = config.root_dir or vim.uv.cwd()
		return vim.lsp.rpc.start(M.command(root, executable, { "server" }), dispatchers, { cwd = root })
	end
end

local function filename_at(root, filename)
	local is_absolute = filename:sub(1, 1) == "/" or filename:match("^%a:[/\\]") ~= nil or filename:sub(1, 2) == "\\\\"
	if is_absolute then
		return filename
	end
	return vim.fs.normalize(vim.fs.joinpath(root, filename))
end

function M.ty_diagnostics(root, output)
	local items = {}
	for _, line in ipairs(vim.split(output, "\n", { plain = true, trimempty = true })) do
		local filename, lnum, col, severity, text = line:match("^(.+):(%d+):(%d+):%s*([^:%s]+):?%s+(.+)$")
		if filename then
			table.insert(items, {
				filename = filename_at(root, filename),
				lnum = tonumber(lnum),
				col = tonumber(col),
				type = severity:lower():find("warning", 1, true) and "W" or "E",
				text = severity .. " " .. text,
			})
		end
	end
	return items
end

function M.pytest_diagnostics(root, output)
	local items = {}
	local project_prefix = vim.fs.normalize(root) .. "/"
	for _, line in ipairs(vim.split(output, "\n", { plain = true, trimempty = true })) do
		local traceback_filename, traceback_lnum = line:match('^E%s+File "(.+%.py)", line (%d+)')
		if traceback_filename then
			table.insert(items, {
				filename = filename_at(root, traceback_filename),
				lnum = tonumber(traceback_lnum),
				col = 1,
				type = "E",
				text = "pytest collection error",
			})
		end

		local filename, lnum, col, text = line:match("^(.+%.py):(%d+):(%d+):%s*(.+)$")
		if not filename then
			filename, lnum, text = line:match("^(.+%.py):(%d+):%s*(.+)$")
		end
		if filename then
			local resolved = filename_at(root, filename)
			if vim.startswith(resolved, project_prefix) then
				table.insert(items, {
					filename = resolved,
					lnum = tonumber(lnum),
					col = tonumber(col) or 1,
					type = "E",
					text = text,
				})
			end
		end
	end
	return items
end

function M.run_quickfix(executable, args, parser)
	local root = M.root(0)
	local command = M.command(root, executable, args)
	vim.system(command, { cwd = root, text = true }, function(result)
		vim.schedule(function()
			local output = (result.stdout or "") .. (result.stderr or "")
			local items = parser(root, output)
			if #items == 0 and result.code ~= 0 then
				items = { { type = "E", text = vim.trim(output) } }
			end
			vim.fn.setqflist({}, " ", { title = table.concat(command, " "), items = items })
			vim.cmd("copen")
			vim.notify(table.concat(command, " ") .. " exited with " .. result.code)
		end)
	end)
end

return M
