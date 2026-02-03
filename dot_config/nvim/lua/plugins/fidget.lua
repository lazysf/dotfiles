return {
  'j-hui/fidget.nvim',
  event = 'LspAttach',
  version = '*',
  opts = {
    notification = {
      override_vim_notify = true,
      window = {
        winblend = 0,
        normal_hl = 'Normal',
        border = 'rounded',
        avoid = { 'NvimTree' },
      },
    },
  },
}
