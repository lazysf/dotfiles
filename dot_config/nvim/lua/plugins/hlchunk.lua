return {
  'shellRaining/hlchunk.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    chunk = {
      enable = true,
      chars = {
        horizontal_line = '─',
        vertical_line = '│',
        left_top = '╭',
        left_bottom = '╰',
        right_arrow = '─',
      },
      -- style = "#80bd9c",
      style = '#00ffff',
      duration = 0,
      delay = 0,
    },
  },
}
