return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local lint = require('lint')

    if lint.linters.selene then
      lint.linters.selene.args = {
        '--std',
        'lua51',
        '--globals',
        'vim',
      }
    end

    lint.linters_by_ft = {
      bash = { 'shellcheck' },
      dockerfile = { 'hadolint' },
      go = { 'golangcilint' },
      javascript = { 'biomejs' },
      javascriptreact = { 'biomejs' },
      lua = { 'selene' },
      markdown = { 'markdownlint' },
      python = { 'ruff' },
      rust = { 'clippy' },
      sh = { 'shellcheck' },
      sql = { 'sqlfluff' },
      typescript = { 'biomejs' },
      typescriptreact = { 'biomejs' },
      yaml = { 'yamllint' },
      yml = { 'yamllint' },
      zsh = { 'zsh' },
    }

    local group = vim.api.nvim_create_augroup('Linting', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = group,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
