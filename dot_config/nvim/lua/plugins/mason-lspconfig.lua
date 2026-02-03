return {
  'mason-org/mason-lspconfig.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'neovim/nvim-lspconfig',
  },
  config = function()
    local opts = {
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
    }
    local mason_lspconfig = require('mason-lspconfig')

    mason_lspconfig.setup(opts)

    local function server_opts(server_name)
      local ok, conf = pcall(require, 'lsp.' .. server_name)
      if ok then
        return conf
      end
      return {}
    end

    local function apply_lsp(server_name)
      local server_conf = server_opts(server_name)
      server_conf.on_attach = vim.g.lsp_on_attach or server_conf.on_attach
      server_conf.capabilities = vim.g.lsp_capabilities or server_conf.capabilities
      local base = vim.lsp.config[server_name] or {}
      vim.lsp.config[server_name] = vim.tbl_deep_extend('force', base, server_conf)
      vim.lsp.enable(server_name)
    end

    if mason_lspconfig.setup_handlers then
      mason_lspconfig.setup_handlers({
        function(server_name)
          apply_lsp(server_name)
        end,
      })
      return
    end

    local servers = opts.ensure_installed or {}
    for _, server_name in ipairs(servers) do
      apply_lsp(server_name)
    end
  end,
}
