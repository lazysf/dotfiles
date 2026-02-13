return {
  {
    'mason-org/mason.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall' },
    opts = {
      PATH = 'append',
    },
  },
  {
    'mason-org/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      ensure_installed = {
        'dockerls',
        'gopls',
        'jsonls',
        'bashls',
        'lua_ls',
        'marksman',
        'pyright',
        'rust_analyzer',
        'sqls',
        'yamlls',
        'taplo',
        'ts_ls',
      },
      automatic_installation = true,
    },
  },
}
