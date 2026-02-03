return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        -- theme = 'tokyonight',
        theme = 'tokyonight',
        icons_enabled = true,
        section_separators = '',
        component_separators = '|',
      },
    },
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },
}
