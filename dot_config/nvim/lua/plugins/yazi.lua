return {
  {
    'mikavilpas/yazi.nvim',
    version = '*',
    event = 'VeryLazy',
    keys = {
      { '<leader>y', '<cmd>Yazi<cr>', mode = 'n', desc = 'Open yazi at the current file' },
    },
    opts = function()
      local centered_width = vim.g.centered_window_width or 80

      return {
        open_for_directories = false,
        keymaps = {
          show_help = '<f1>',
        },
        hooks = {
          before_opening_window = function(window_options)
            local max_width = math.max(20, vim.o.columns - 4)
            local width = math.min(centered_width, max_width)
            window_options.width = width
            window_options.col = math.floor((vim.o.columns - width) / 2)
          end,
        },
      }
    end,
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  { 'nvim-lua/plenary.nvim', lazy = true },
}
