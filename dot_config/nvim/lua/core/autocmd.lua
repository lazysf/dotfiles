local center_special_group = vim.api.nvim_create_augroup('center-special-buffers', { clear = true })

local special_filetypes = {
  checkhealth = true,
  help = true,
  lazy = true,
  lspinfo = true,
  man = true,
  mason = true,
  qf = true,
  trouble = true,
}

local special_buftypes = {
  help = true,
  quickfix = true,
}

local function should_recenter(bufnr)
  if vim.api.nvim_win_get_config(0).relative ~= '' then
    return false
  end

  local filetype = vim.bo[bufnr].filetype
  local buftype = vim.bo[bufnr].buftype
  return special_filetypes[filetype] or special_buftypes[buftype]
end

local function recenter_special_buffer(args)
  if not should_recenter(args.buf) then
    return
  end

  local ok, no_neck_pain = pcall(require, 'no-neck-pain')
  if not ok then
    return
  end

  vim.schedule(function()
    pcall(no_neck_pain.enable, 'center_special_buffer')
  end)
end

vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
  group = center_special_group,
  pattern = '*',
  callback = recenter_special_buffer,
})

local reopen_group = vim.api.nvim_create_augroup('reopen-with-encoding', { clear = true })
local reopen_encodings = require('core.encoding_map')

for pattern, rule in pairs(reopen_encodings) do
  local encoding = rule.encoding
  local fileformat = rule.fileformat

  vim.api.nvim_create_autocmd('BufReadPost', {
    group = reopen_group,
    pattern = pattern,
    callback = function(args)
      if vim.b[args.buf].reopened_with_encoding then
        return
      end

      vim.b[args.buf].reopened_with_encoding = true
      vim.api.nvim_buf_call(args.buf, function()
        vim.cmd(('silent noautocmd keepjumps edit ++enc=%s'):format(encoding))
      end)
      vim.bo[args.buf].fileencoding = encoding
      if fileformat then
        vim.bo[args.buf].fileformat = fileformat
      end
    end,
  })

  vim.api.nvim_create_autocmd('BufNewFile', {
    group = reopen_group,
    pattern = pattern,
    callback = function(args)
      vim.bo[args.buf].fileencoding = encoding
      if fileformat then
        vim.bo[args.buf].fileformat = fileformat
      end
    end,
  })
end

local indent_group = vim.api.nvim_create_augroup('filetype-indent-overrides', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = indent_group,
  pattern = 'go',
  callback = function(args)
    vim.bo[args.buf].expandtab = false
    vim.bo[args.buf].tabstop = 4
    vim.bo[args.buf].softtabstop = 4
    vim.bo[args.buf].shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = indent_group,
  pattern = { 'python', 'rust' },
  callback = function(args)
    vim.bo[args.buf].expandtab = true
    vim.bo[args.buf].tabstop = 4
    vim.bo[args.buf].softtabstop = 4
    vim.bo[args.buf].shiftwidth = 4
  end,
})
