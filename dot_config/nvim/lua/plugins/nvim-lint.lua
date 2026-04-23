return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local api = vim.api
		local lint = require("lint")
		local parser = require("lint.parser")
		local taplo_config = require("core.taplo_config")
		local taplo_lint = require("core.taplo_lint")

		local function taplo_parser(output, bufnr, linter_cwd)
			if not api.nvim_buf_is_valid(bufnr) then
				return {}
			end

			return taplo_lint.parse_taplo_stderr(output, api.nvim_buf_get_name(bufnr), linter_cwd)
		end

		-- Force zsh lint to syntax-check mode (`zsh -n`).
		if lint.linters.zsh then
			lint.linters.zsh.cmd = "zsh"
			lint.linters.zsh.args = { "-n" }
		else
			lint.linters.zsh = {
				cmd = "zsh",
				args = { "-n" },
				stdin = false,
				append_fname = true,
				stream = "stderr",
				ignore_exitcode = true,
				parser = parser.from_errorformat("%f:%l: %m", { source = "zsh" }),
			}
		end

		local base_taplo = lint.linters.taplo or {}

		-- TOML lint with taplo.
		lint.linters.taplo = function()
			local bufnr = api.nvim_get_current_buf()
			local filename = api.nvim_buf_get_name(bufnr)

			return vim.tbl_extend("force", base_taplo, {
				cmd = "taplo",
				args = { "lint", "--colors", "never" },
				stdin = false,
				append_fname = true,
				stream = "stderr",
				ignore_exitcode = true,
				cwd = taplo_config.find_root(filename) or vim.fn.fnamemodify(filename, ":h"),
				parser = taplo_parser,
			})
		end

		-- Markdown lint with markdownlint-cli2.
		if not lint.linters.markdownlint_cli2 then
			lint.linters.markdownlint_cli2 = {
				cmd = "markdownlint-cli2",
				args = { "--no-globs" },
				stdin = false,
				append_fname = true,
				stream = "stdout",
				ignore_exitcode = true,
				parser = parser.from_pattern(
					"([^:]+):(%d+):(%d+)%s+(%w+)%s+(.+)",
					{ "file", "lnum", "col", "severity", "message" },
					{
						error = vim.diagnostic.severity.WARN,
						warning = vim.diagnostic.severity.WARN,
					},
					{ source = "markdownlint-cli2" }
				),
			}
		end

		lint.linters_by_ft = {
			bash = { "shellcheck" },
			dockerfile = { "hadolint" },
			go = { "golangcilint" },
			javascript = { "biomejs" },
			javascriptreact = { "biomejs" },
			json = { "biomejs" },
			jsonc = { "biomejs" },
			lua = { "selene" },
			markdown = { "markdownlint_cli2" },
			python = { "ruff" },
			rust = { "clippy" },
			sh = { "shellcheck" },
			sql = { "sqlfluff" },
			toml = { "taplo" },
			typescript = { "biomejs" },
			typescriptreact = { "biomejs" },
			yaml = { "yamllint" },
			yml = { "yamllint" },
			zsh = { "zsh" },
		}

		local function try_lint_buffer(bufnr)
			if not api.nvim_buf_is_valid(bufnr) then
				return
			end

			if vim.bo[bufnr].filetype == "toml" and taplo_config.is_excluded(api.nvim_buf_get_name(bufnr)) then
				vim.diagnostic.reset(lint.get_namespace("taplo"), bufnr)
				return
			end

			lint.try_lint()
		end

		local group = vim.api.nvim_create_augroup("Linting", { clear = true })
		vim.api.nvim_create_autocmd("BufReadPost", {
			group = group,
			callback = function(args)
				vim.defer_fn(function()
					if api.nvim_buf_is_valid(args.buf) then
						api.nvim_buf_call(args.buf, function()
							try_lint_buffer(args.buf)
						end)
					end
				end, 800)
			end,
		})
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			callback = function(args)
				api.nvim_buf_call(args.buf, function()
					try_lint_buffer(args.buf)
				end)
			end,
		})
	end,
}
