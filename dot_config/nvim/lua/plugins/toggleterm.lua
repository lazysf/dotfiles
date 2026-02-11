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
  opts = {
    open_mapping = false,
    insert_mappings = false,
    direction = 'float',
    shade_terminals = true,
    float_opts = {
      border = 'rounded',
    },
  },
}
