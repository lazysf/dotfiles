return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  keys = {
    {
      '<leader>xx',
      function()
        require('trouble').toggle('diagnostics')
      end,
      mode = 'n',
      desc = 'Trouble diagnostics (workspace)',
    },
    {
      '<leader>xb',
      function()
        require('trouble').toggle('diagnostics', { filter = { buf = 0 } })
      end,
      mode = 'n',
      desc = 'Trouble diagnostics (buffer)',
    },
    {
      '<leader>xq',
      function()
        require('trouble').toggle('qflist')
      end,
      mode = 'n',
      desc = 'Trouble quickfix list',
    },
    {
      '<leader>xl',
      function()
        require('trouble').toggle('loclist')
      end,
      mode = 'n',
      desc = 'Trouble location list',
    },
  },
  opts = {
    focus = false,
  },
}
