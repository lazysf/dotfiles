return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {},
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
