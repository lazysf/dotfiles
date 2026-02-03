return {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.stdpath('config') .. '/lua',
        },
        checkThirdParty = false,
        maxPreload = 2000,
        preloadFileSize = 400,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
