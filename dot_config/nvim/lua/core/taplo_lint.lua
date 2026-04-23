local M = {}

function M.normalize_path(path, linter_cwd)
	if not path or path == "" then
		return nil
	end

	local absolute_path = path
	if not path:match("^%a:[/\\]") and not path:match("^/") then
		absolute_path = vim.fn.fnamemodify((linter_cwd or ".") .. "/" .. path, ":p")
	else
		absolute_path = vim.fn.fnamemodify(path, ":p")
	end

	if vim.fs and vim.fs.normalize then
		return vim.fs.normalize(absolute_path)
	end

	return absolute_path
end

-- Taplo 0.10 emits an `error:` summary followed by a location line on stderr.
function M.parse_taplo_stderr(output, buffer_path, linter_cwd)
	local normalized_buffer_path = M.normalize_path(buffer_path, linter_cwd)
	if not normalized_buffer_path then
		return {}
	end

	local diagnostics = {}
	local pending_message

	for line in vim.gsplit(output, "\n", true) do
		local message = line:match("^error:%s+(.+)$")
		if message then
			pending_message = message
		else
			local file, lnum, col = line:match("^%s*┌─%s+(.+):(%d+):(%d+)$")
			if file and pending_message then
				if M.normalize_path(file, linter_cwd) == normalized_buffer_path then
					table.insert(diagnostics, {
						lnum = math.max(0, tonumber(lnum) - 1),
						end_lnum = math.max(0, tonumber(lnum) - 1),
						col = math.max(0, tonumber(col) - 1),
						end_col = math.max(0, tonumber(col) - 1),
						severity = vim.diagnostic.severity.ERROR,
						message = pending_message,
						source = "taplo",
					})
				end
				pending_message = nil
			end
		end
	end

	return diagnostics
end

return M
