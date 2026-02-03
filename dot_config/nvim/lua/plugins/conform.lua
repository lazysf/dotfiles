return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format({ async = true, lsp_fallback = false })
      end,
      mode = 'n',
      desc = 'Format',
    },
  },
  opts = {
    format_on_save = {
      timeout_ms = 2000,
      lsp_fallback = false,
    },
    formatters = {
      ruff_format = {
        command = 'ruff',
        args = { 'format', '--stdin-filename', '$FILENAME', '-' },
        stdin = true,
      },
      biome = {
        command = 'biome',
        args = { 'format', '--stdin-file-path', '$FILENAME' },
        stdin = true,
      },
      gofmt = {
        command = 'gofmt',
        stdin = true,
      },
      shfmt = {
        command = 'shfmt',
        args = { '-ln', 'zsh' },
        stdin = true,
      },
      rustfmt = {
        command = 'rustfmt',
        args = { '--edition', '2021' },
        stdin = true,
      },
      taplo = {
        command = 'taplo',
        args = { 'format', '--stdin-file-path', '$FILENAME', '-' },
        stdin = true,
      },
      sqlfluff = {
        command = 'sqlfluff',
        args = { 'format', '--stdin-file-path', '$FILENAME', '-' },
        stdin = true,
      },
      stylua = {
        prepend_args = {
          '--column-width',
          '100',
          '--indent-type',
          'Spaces',
          '--indent-width',
          '2',
          '--line-endings',
          'Unix',
          '--quote-style',
          'AutoPreferSingle',
        },
      },
    },
    formatters_by_ft = {
      bash = { 'shfmt' },
      go = { 'gofmt' },
      javascript = { 'biome' },
      javascriptreact = { 'biome' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      lua = { 'stylua' },
      markdown = { 'prettier' },
      python = { 'ruff_format' },
      rust = { 'rustfmt' },
      sh = { 'shfmt' },
      sql = { 'sqlfluff' },
      toml = { 'taplo' },
      typescript = { 'biome' },
      typescriptreact = { 'biome' },
      yaml = { 'prettier' },
      yml = { 'prettier' },
      zsh = { 'shfmt' },
    },
  },
}
