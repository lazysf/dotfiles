return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = function()
    local centered_width = vim.g.centered_window_width or 80

    return {
      win = {
        border = 'rounded',
        col = 0.5,
        row = 0.5,
        no_overlap = false,
        width = {
          max = centered_width,
        },
      },
      layout = {
        width = {
          max = centered_width,
        },
      },
    }
  end,
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show({ global = false })
      end,
      mode = 'n',
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
}
