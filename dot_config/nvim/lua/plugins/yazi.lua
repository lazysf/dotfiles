return {
  {
    'mikavilpas/yazi.nvim',
    version = '*',
    event = 'VeryLazy',
    keys = {
      { '<leader>y', '<cmd>Yazi<cr>', mode = 'n', desc = 'Open yazi at the current file' },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  { 'nvim-lua/plenary.nvim', lazy = true },
}
