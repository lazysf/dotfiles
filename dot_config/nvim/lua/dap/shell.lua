return function(dap)
  local function mason_bin(package_name, bin_name)
    local path = string.format('%s/mason/packages/%s/%s', vim.fn.stdpath('data'), package_name, bin_name)
    if vim.fn.executable(path) == 1 then
      return path
    end

    local exepath = vim.fn.exepath(bin_name)
    if exepath ~= '' then
      return exepath
    end
    return nil
  end

  local bash_adapter = mason_bin('bash-debug-adapter', 'bash-debug-adapter')
  if not bash_adapter then
    vim.notify(
      'bash-debug-adapter が見つかりません。:Mason で bash-debug-adapter を確認してください。',
      vim.log.levels.WARN
    )
    return
  end

  dap.adapters.bash = {
    type = 'executable',
    command = bash_adapter,
    name = 'bash',
  }

  local bash_config = {
    {
      type = 'bash',
      request = 'launch',
      name = 'Launch file (bash)',
      program = '${file}',
      cwd = '${workspaceFolder}',
      pathBash = '/bin/bash',
    },
  }

  dap.configurations.sh = bash_config
  dap.configurations.bash = bash_config
  dap.configurations.zsh = bash_config
end
