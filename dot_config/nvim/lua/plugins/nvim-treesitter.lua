return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  event = { 'BufReadPost', 'BufNewFile' },
  build = ':TSUpdate',
  config = function()
    local ts = require('nvim-treesitter')

    ts.setup({})

    -- Parsers are installed manually via :TSUpdate or :TSInstall.

    local group = vim.api.nvim_create_augroup('TreesitterConfig', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
