-- File explorer (netrw)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Shared UI sizing
vim.g.centered_window_width = 80
vim.g.health = {
  style = nil,
}

-- UI: numbers, cursor, and matching
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'
vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = '80'
vim.opt.showmatch = true
vim.opt.matchtime = 2

-- UI: splits
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = 'screen'

-- UI: scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- UI: colors, popups, and rendering
vim.opt.termguicolors = true
vim.opt.winblend = 10
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.showmode = false
vim.opt.conceallevel = 0
vim.opt.concealcursor = ''
vim.opt.lazyredraw = false
vim.opt.synmaxcol = 300

-- Editing: tabs
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- Editing: indent and wrapping
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Search behavior
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Clipboard and mouse
vim.opt.clipboard = 'unnamedplus'
vim.opt.mouse = 'a'

-- Encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- Undo history
vim.opt.undofile = true
local undodir = vim.fn.stdpath('state') .. '/undo'
vim.opt.undodir = undodir
vim.fn.mkdir(undodir, 'p')

-- Timings and command preview
vim.opt.updatetime = 200
vim.opt.timeoutlen = 400
vim.opt.ttimeoutlen = 0
vim.opt.inccommand = 'split'

-- Cursor shape
vim.opt.guicursor = 'a:ver25-blinkon500-blinkoff500-blinkwait500'

-- Whitespace visualization
vim.opt.list = true
vim.opt.listchars = 'space:·,tab:>-,trail:·,extends:>,precedes:<,nbsp:+'

-- File handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.autowrite = false

-- General behavior
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = 'indent,eol,start'
vim.opt.iskeyword:append('-')
vim.opt.path:append('**')
vim.opt.selection = 'exclusive'
