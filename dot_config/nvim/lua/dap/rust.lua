return function(dap)
  dap.configurations.rust = {
    {
      name = 'Launch executable',
      type = 'codelldb',
      request = 'launch',
      program = function()
        local default_path = vim.fn.getcwd() .. '/target/debug/'
        return vim.fn.input('Path to executable: ', default_path, 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
    },
  }
end
