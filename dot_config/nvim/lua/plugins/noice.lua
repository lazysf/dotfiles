return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = function()
      local centered_width = vim.g.centered_window_width or 80
      local max_width = math.max(40, vim.o.columns - 4)
      local float_width = math.min(centered_width, max_width)
      local cmdline_row = math.max(2, math.floor(vim.o.lines * 0.5))
      local popup_row = math.min(vim.o.lines - 4, cmdline_row + 3)
      local popup_max_height = math.max(6, vim.o.lines - popup_row - 2)

      return {
        cmdline = {
          enabled = true,
          view = 'cmdline_popup',
        },
        notify = {
          enabled = false,
        },
        popupmenu = {
          enabled = true,
          backend = 'nui',
        },
        views = {
          cmdline_popup = {
            relative = 'editor',
            anchor = 'NW',
            position = {
              row = cmdline_row,
              col = '50%',
            },
            size = {
              width = float_width,
              height = 1,
            },
            border = {
              style = 'rounded',
              padding = { 0, 1 },
            },
          },
          popupmenu = {
            relative = 'editor',
            anchor = 'NW',
            position = {
              row = popup_row,
              col = '50%',
            },
            size = {
              width = float_width,
              height = 'auto',
              max_height = popup_max_height,
            },
            border = {
              style = 'rounded',
              padding = { 0, 1 },
            },
          },
          cmdline_popupmenu = {
            relative = 'editor',
            anchor = 'NW',
            position = {
              row = popup_row,
              col = '50%',
            },
            size = {
              width = float_width,
              height = 'auto',
              max_height = popup_max_height,
            },
            border = {
              style = 'rounded',
              padding = { 0, 1 },
            },
          },
        },
        presets = {
          command_palette = false,
        },
      }
    end,
  },
  { 'MunifTanjim/nui.nvim', lazy = true },
}
