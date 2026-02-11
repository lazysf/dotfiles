return {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local on_attach = function(client, bufnr)
      local map = vim.keymap.set
      local opts = { buffer = bufnr, silent = true }

      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false

      map(
        'n',
        'gd',
        vim.lsp.buf.definition,
        vim.tbl_extend('force', opts, { desc = 'LSP go to definition' })
      )
      map('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'LSP hover' }))
      map(
        'n',
        '<leader>rn',
        vim.lsp.buf.rename,
        vim.tbl_extend('force', opts, { desc = 'LSP rename' })
      )
      map(
        'n',
        '<leader>ca',
        vim.lsp.buf.code_action,
        vim.tbl_extend('force', opts, { desc = 'LSP code action' })
      )
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if ok then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    vim.diagnostic.config({
      signs = true,
      underline = true,
      virtual_text = false,
      update_in_insert = false,
      severity_sort = true,
      float = { border = 'rounded' },
    })

    vim.api.nvim_create_autocmd('CursorHold', {
      group = vim.api.nvim_create_augroup('LspDiagnosticsOnHover', { clear = true }),
      callback = function()
        vim.diagnostic.open_float(nil, {
          focusable = false,
          scope = 'cursor',
        })
      end,
    })

    local servers = {
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
    }

    local function server_opts(server_name)
      local ok, conf = pcall(require, 'lsp.' .. server_name)
      if ok then
        return conf
      end
      return {}
    end

    for _, server_name in ipairs(servers) do
      local server_conf = server_opts(server_name)
      server_conf.on_attach = on_attach
      server_conf.capabilities = capabilities

      local base = vim.lsp.config[server_name] or {}
      vim.lsp.config[server_name] = vim.tbl_deep_extend('force', base, server_conf)
      vim.lsp.enable(server_name)
    end
  end,
}
