return function(dap)
  require('dap-vscode-js').setup({
    debugger_path = vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter',
    adapters = {
      'pwa-node',
    },
  })

  local js_like = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }
  local js_config = {
    {
      name = 'Launch file (Node)',
      type = 'pwa-node',
      request = 'launch',
      program = '${file}',
      cwd = '${workspaceFolder}',
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
  }

  for _, ft in ipairs(js_like) do
    dap.configurations[ft] = js_config
  end
end
