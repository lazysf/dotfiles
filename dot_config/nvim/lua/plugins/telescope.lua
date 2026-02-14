return {
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    cmd = 'Telescope',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>', mode = 'n', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<CR>', mode = 'n', desc = 'Live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<CR>', mode = 'n', desc = 'Find buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<CR>', mode = 'n', desc = 'Help tags' },
    },
    opts = function()
      local centered_width = vim.g.centered_window_width or 80

      local telescope = require('telescope')
      local actions = require('telescope.actions')

      telescope.setup({
        defaults = {
          layout_strategy = 'horizontal',
          layout_config = {
            width = centered_width,
            height = 0.85,
            preview_cutoff = 90,
          },
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
          },
        },
      })

      telescope.load_extension('fzf')
    end,
  },
  { 'nvim-lua/plenary.nvim', lazy = true },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', lazy = true },
}
