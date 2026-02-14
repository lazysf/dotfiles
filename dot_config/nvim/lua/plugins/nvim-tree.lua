return {
  {
    'nvim-tree/nvim-tree.lua',
    keys = {
      { '<leader>e', '<cmd>NvimTreeToggle<CR>', mode = 'n', desc = 'Toggle file explorer' },
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      view = {
        width = 34,
        side = 'left',
        number = true,
        relativenumber = false,
      },
      renderer = {
        indent_markers = { enable = true },
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
            folder_arrow = true,
          },
        },
      },
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      diagnostics = {
        enable = true,
        show_on_dirs = true,
      },
      git = {
        enable = true,
      },
      actions = {
        open_file = {
          resize_window = true,
        },
      },
      filters = {
        dotfiles = false,
      },
    },
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },
}
