return {
  {
    'mason-org/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall' },
    opts = function()
      local centered_width = vim.g.centered_window_width or 80
      local max_width = math.max(60, vim.o.columns - 4)

      return {
        PATH = 'append',
        ui = {
          border = 'rounded',
          width = math.min(centered_width + 6, max_width),
          height = 0.85,
        },
      }
    end,
  },
  {
    'mason-org/mason-lspconfig.nvim',
    event = 'VeryLazy',
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
