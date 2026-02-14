return {
  'shortcuts/no-neck-pain.nvim',
  lazy = false,
  priority = 900,
  config = function()
    local centered_width = vim.g.centered_window_width or 80

    require('no-neck-pain').setup({
      width = centered_width,
      autocmds = {
        enableOnTabEnter = true,
      },
      buffers = {
        bo = {
          filetype = 'no-neck-pain-side',
        },
        left = { enabled = true },
        right = { enabled = true },
        scratchPad = {
          enabled = false,
        },
        colors = {
          bo = {
            filetype = 'md',
          },
          blend = 0.8,
        },
      },
    })
    vim.cmd('NoNeckPain')
  end,
}
