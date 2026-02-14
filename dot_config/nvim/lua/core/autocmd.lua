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
