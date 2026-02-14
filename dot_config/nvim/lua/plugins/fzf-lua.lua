return {
  {
    'ibhagwan/fzf-lua',
    cmd = { 'FzfLua' },
    opts = function()
      local centered_width = vim.g.centered_window_width or 80
      local max_width = math.max(60, vim.o.columns - 4)

      return {
        winopts = {
          width = math.min(centered_width, max_width),
          height = 0.85,
          row = 0.5,
          col = 0.5,
          border = 'rounded',
        },
      }
    end,
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },
}
