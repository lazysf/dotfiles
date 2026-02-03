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

    vim.g.lsp_on_attach = on_attach
    vim.g.lsp_capabilities = capabilities

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
  end,
}
