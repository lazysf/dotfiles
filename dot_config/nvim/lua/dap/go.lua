return function(dap)
  dap.configurations.go = {
    {
      name = 'Debug package',
      type = 'delve',
      request = 'launch',
      program = '${fileDirname}',
    },
    {
      name = 'Debug file',
      type = 'delve',
      request = 'launch',
      program = '${file}',
    },
  }
end
