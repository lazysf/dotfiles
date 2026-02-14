-- Leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opts = { noremap = true, silent = true }

-- Insert/visual mode: quick escape
vim.keymap.set({ 'i', 'v' }, 'jk', '<ESC>', opts)

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Window resize
-- Alt+j/k: increase/decrease height, Alt+h/l: decrease/increase width
vim.keymap.set('n', '<M-j>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<M-k>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<M-h>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<M-l>', ':vertical resize +2<CR>', opts)

-- Buffer navigation
vim.keymap.set('n', '[b', ':bprev<CR>', opts)
vim.keymap.set('n', ']b', ':bnext<CR>', opts)

-- Safety: disable accident-prone keys/modes
vim.keymap.set('n', 'Q', '<Nop>', opts) -- Ex mode
vim.keymap.set('n', 'q', '<Nop>', opts) -- macro record / command-line window
vim.keymap.set('n', '@', '<Nop>', opts) -- macro playback
vim.keymap.set('n', 'ZZ', '<Nop>', opts) -- write & quit
vim.keymap.set('n', 'ZQ', '<Nop>', opts) -- quit without write
vim.keymap.set('n', 'R', '<Nop>', opts) -- replace mode
vim.keymap.set('n', 'gR', '<Nop>', opts) -- virtual replace mode
vim.keymap.set('n', '<C-z>', '<Nop>', opts) -- suspend
vim.keymap.set('n', 's', '<Nop>', opts) -- substitute char
vim.keymap.set('n', 'S', '<Nop>', opts) -- substitute line

-- Normal mode editing
vim.keymap.set('n', 'J', 'mzJ`z', opts)
vim.keymap.set(
  'n',
  '<C-d>',
  '<C-d>zz',
  vim.tbl_extend('force', opts, { desc = 'move down in buffer with cursor centered' })
)
vim.keymap.set(
  'n',
  '<C-u>',
  '<C-u>zz',
  vim.tbl_extend('force', opts, { desc = 'move up in buffer with cursor centered' })
)
vim.keymap.set('n', 'x', '"_x', opts)

-- Visual mode editing
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)
vim.keymap.set(
  'v',
  'J',
  ":m '>+1<CR>gv=gv",
  vim.tbl_extend('force', opts, { desc = 'moves lines down in visual selection' })
)
vim.keymap.set(
  'v',
  'K',
  ":m '<-2<CR>gv=gv",
  vim.tbl_extend('force', opts, { desc = 'moves lines up in visual selection' })
)

-- Yank highlight
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
