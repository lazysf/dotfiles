local function resolve_python(workspace)
  if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= '' then
    local from_env = vim.fs.joinpath(vim.env.VIRTUAL_ENV, 'bin', 'python')
    if vim.fn.executable(from_env) == 1 then
      return from_env
    end
  end

  local from_venv = vim.fs.joinpath(workspace, '.venv', 'bin', 'python')
  if vim.fn.executable(from_venv) == 1 then
    return from_venv
  end

  local py3 = vim.fn.exepath('python3')
  if py3 ~= '' then
    return py3
  end

  return vim.fn.exepath('python')
end

return {
  before_init = function(_, config)
    local uv = vim.uv or vim.loop
    local root = config.root_dir or uv.cwd()
    local python = resolve_python(root)

    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = python

    local project_venv = vim.fs.joinpath(root, '.venv')
    if vim.fn.isdirectory(project_venv) == 1 then
      config.settings.python.venvPath = root
    end
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'basic', -- strict にしてもOK
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}
