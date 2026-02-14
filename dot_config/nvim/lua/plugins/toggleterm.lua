return {
  'akinsho/toggleterm.nvim',
  version = '*',
  cmd = {
    'ToggleTerm',
    'ToggleTermToggleAll',
    'TermExec',
    'ToggleTermSendCurrentLine',
    'ToggleTermSendVisualLines',
    'ToggleTermSendVisualSelection',
    'ToggleTermSetName',
  },
  keys = {
    { '<leader>t', '<cmd>ToggleTerm<CR>', mode = 'n', desc = 'Toggle terminal' },
    { '<leader>t', [[<C-\><C-n><cmd>ToggleTerm<CR>]], mode = 't', desc = 'Toggle terminal' },
  },
  opts = function()
    local centered_width = vim.g.centered_window_width or 80

    return {
      open_mapping = false,
      insert_mappings = false,
      direction = 'float',
      shade_terminals = true,
      float_opts = {
        border = 'rounded',
        width = function()
          local max_width = math.max(20, vim.o.columns - 4)
          return math.min(centered_width, max_width)
        end,
      },
    }
  end,
}
