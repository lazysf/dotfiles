return function(dap)
  local function resolve_python()
    if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= '' then
      return vim.env.VIRTUAL_ENV .. '/bin/python'
    end

    local venv = vim.fn.getcwd() .. '/.venv/bin/python'
    if vim.fn.executable(venv) == 1 then
      return venv
    end

    local py = vim.fn.exepath('python3')
    if py ~= '' then
      return py
    end
    return 'python'
  end

  dap.configurations.python = {
    {
      name = 'Launch file',
      type = 'python',
      request = 'launch',
      program = '${file}',
      pythonPath = resolve_python,
    },
  }
end
