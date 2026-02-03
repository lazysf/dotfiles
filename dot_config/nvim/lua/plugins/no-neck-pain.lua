return {
  'shortcuts/no-neck-pain.nvim',
  lazy = false,
  priority = 900,
  config = function()
    require('no-neck-pain').setup({
      width = 80,
      buffers = {
        left = { enabled = true },
        right = { enabled = false },
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
