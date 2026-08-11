local M = {}

local attached = {}

local function buffer_path(buf)
	local path = vim.api.nvim_buf_get_name(buf)
	if path == "" then
		return nil
	end
	return vim.fs.normalize(path)
end

local function learning_root(path)
	local root = path and vim.fs.root(path, { "pyproject.toml", "uv.lock", ".git" }) or nil
	if root and vim.uv.fs_stat(vim.fs.joinpath(root, "curriculum", "sequence.json")) then
		return root
	end
	return nil
end

local function exercise_slug(path)
	local normalized = path:gsub("\\", "/")
	return normalized:match("/exercises/[^/]+/([^/]+)/") or normalized:match("/tests/exercism/([^/]+)/")
end

local function is_test_file(path)
	local name = vim.fs.basename(path)
	return name:match("^test_.*%.py$") ~= nil or name:match("_test%.py$") ~= nil
end

local function open_terminal(root, command)
	Snacks.terminal.open(command, { cwd = root })
end

local function warn(message)
	vim.notify(message, vim.log.levels.WARN, { title = "Python Learning" })
end

local function run_exercise_suite(buf)
	local path = buffer_path(buf)
	local root = learning_root(path)
	local slug = path and exercise_slug(path) or nil
	if not root or not slug then
		warn("Current buffer is not inside an Exercism exercise")
		return
	end
	open_terminal(root, { "just", "test", slug })
end

local function run_test_file(buf)
	local path = buffer_path(buf)
	local root = learning_root(path)
	if not root or not path or not is_test_file(path) then
		warn("Current buffer is not a test file in the learning repository")
		return
	end
	open_terminal(root, { "just", "test-file", path })
end

local function run_relevant_tests(buf)
	local path = buffer_path(buf)
	if path and is_test_file(path) then
		run_test_file(buf)
		return
	end
	run_exercise_suite(buf)
end

local function attach(buf)
	if attached[buf] or vim.bo[buf].filetype ~= "python" then
		return
	end
	attached[buf] = true

	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
	end

	map("n", "<leader>pr", function()
		require("uv").run_file()
	end, "Python: run file")
	map("v", "<leader>ps", function()
		require("uv").run_python_selection()
	end, "Python: run selection")
	map("n", "<leader>pf", function()
		require("uv").run_python_function()
	end, "Python: run function")

	local path = buffer_path(buf)
	if not learning_root(path) then
		return
	end
	map("n", "<leader>tr", function()
		run_relevant_tests(buf)
	end, "Test: run relevant")
	map("n", "<leader>tf", function()
		run_test_file(buf)
	end, "Test: run file")
	map("n", "<leader>ta", function()
		run_exercise_suite(buf)
	end, "Test: run exercise suite")
end

function M.setup()
	local group = vim.api.nvim_create_augroup("python_learning", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "python",
		callback = function(args)
			attach(args.buf)
		end,
	})

	attach(vim.api.nvim_get_current_buf())
end

return M
