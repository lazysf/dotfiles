return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local parser = require("lint.parser")

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

		-- TOML lint with taplo.
		if not lint.linters.taplo then
			lint.linters.taplo = {
				cmd = "taplo",
				args = { "check", "--no-color" },
				stdin = false,
				append_fname = true,
				stream = "stderr",
				ignore_exitcode = true,
				parser = parser.from_errorformat("%f:%l:%c: %m", { source = "taplo" }),
			}
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

		local group = vim.api.nvim_create_augroup("Linting", { clear = true })
		vim.api.nvim_create_autocmd("BufReadPost", {
			group = group,
			callback = function()
				vim.defer_fn(function()
					lint.try_lint()
				end, 800)
			end,
		})
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
