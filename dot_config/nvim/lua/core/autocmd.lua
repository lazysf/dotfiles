local reopen_group = vim.api.nvim_create_augroup("reopen-with-encoding", { clear = true })
local reopen_encodings = require("core.encoding_map")

for pattern, rule in pairs(reopen_encodings) do
	local encoding = rule.encoding
	local fileformat = rule.fileformat
	local bomb = rule.bomb

	vim.api.nvim_create_autocmd("BufReadPost", {
		group = reopen_group,
		pattern = pattern,
		callback = function(args)
			if vim.b[args.buf].reopened_with_encoding then
				return
			end

			vim.b[args.buf].reopened_with_encoding = true
			vim.api.nvim_buf_call(args.buf, function()
				vim.cmd(("silent noautocmd keepjumps edit ++enc=%s"):format(encoding))
			end)
			vim.bo[args.buf].fileencoding = encoding
			if fileformat then
				vim.bo[args.buf].fileformat = fileformat
			end
			if bomb ~= nil then
				vim.bo[args.buf].bomb = bomb
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufNewFile", {
		group = reopen_group,
		pattern = pattern,
		callback = function(args)
			vim.bo[args.buf].fileencoding = encoding
			if fileformat then
				vim.bo[args.buf].fileformat = fileformat
			end
			if bomb ~= nil then
				vim.bo[args.buf].bomb = bomb
			end
		end,
	})
end

local indent_group = vim.api.nvim_create_augroup("filetype-indent-overrides", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = indent_group,
	pattern = "go",
	callback = function(args)
		vim.bo[args.buf].expandtab = false
		vim.bo[args.buf].tabstop = 4
		vim.bo[args.buf].softtabstop = 4
		vim.bo[args.buf].shiftwidth = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = indent_group,
	pattern = { "python", "rust" },
	callback = function(args)
		vim.bo[args.buf].expandtab = true
		vim.bo[args.buf].tabstop = 4
		vim.bo[args.buf].softtabstop = 4
		vim.bo[args.buf].shiftwidth = 4
	end,
})
