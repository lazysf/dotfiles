local M = {}

local config_markers = { ".taplo.toml", "taplo.toml" }

local function normalize_path(path)
	if not path or path == "" then
		return nil
	end

	local absolute_path = vim.fn.fnamemodify(path, ":p")
	if vim.fs and vim.fs.normalize then
		return vim.fs.normalize(absolute_path)
	end

	return absolute_path
end

local function dirname(path)
	return vim.fn.fnamemodify(path, ":h")
end

local function normalize_relative_path(path)
	return (path:gsub("\\", "/"))
end

function M.find_config_path(path)
	local start = path
	if not start or start == "" then
		start = vim.fn.getcwd()
	end

	start = normalize_path(start)
	if not start then
		return nil
	end

	if vim.fn.isdirectory(start) == 0 then
		start = dirname(start)
	end

	if vim.fs and vim.fs.find then
		local found = vim.fs.find(config_markers, {
			path = start,
			upward = true,
			stop = vim.loop.os_homedir(),
		})[1]
		return normalize_path(found)
	end

	for _, marker in ipairs(config_markers) do
		local found = vim.fn.findfile(marker, start .. ";")
		if found ~= "" then
			return normalize_path(found)
		end
	end

	return nil
end

function M.find_root(path)
	local config_path = M.find_config_path(path)
	if not config_path then
		return nil
	end

	return dirname(config_path)
end

function M.read_excludes(path)
	local config_path = M.find_config_path(path)
	if not config_path then
		return {}
	end

	local ok, lines = pcall(vim.fn.readfile, config_path)
	if not ok then
		return {}
	end

	local content = table.concat(lines, "\n")
	local exclude_block = content:match("exclude%s*=%s*%[(.-)%]")
	if not exclude_block then
		return {}
	end

	local excludes = {}
	for entry in exclude_block:gmatch('"(.-)"') do
		table.insert(excludes, normalize_relative_path(entry))
	end

	return excludes
end

function M.relative_to_root(path, root)
	local normalized_path = normalize_path(path)
	local normalized_root = normalize_path(root)
	if not normalized_path or not normalized_root then
		return nil
	end

	local prefix = normalized_root
	if prefix:sub(-1) ~= "/" then
		prefix = prefix .. "/"
	end

	if normalized_path:sub(1, #prefix) ~= prefix then
		return nil
	end

	return normalize_relative_path(normalized_path:sub(#prefix + 1))
end

function M.is_excluded(path)
	local root = M.find_root(path)
	if not root then
		return false
	end

	local relative_path = M.relative_to_root(path, root)
	if not relative_path then
		return false
	end

	for _, excluded in ipairs(M.read_excludes(root)) do
		if excluded == relative_path then
			return true
		end
	end

	return false
end

return M
