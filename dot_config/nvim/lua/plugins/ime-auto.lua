return {
  'shabaraba/ime-auto.nvim',
  event = { 'InsertEnter', 'FocusGained' },
  opts = {
    escape_sequence = 'jk',
    escape_timeout = 100,
    os = 'auto',
    ime_method = 'builtin',
    debug = false,
  },
  config = function(_, opts)
    local ime_auto = require('ime-auto')
    ime_auto.setup(opts)

    local group = vim.api.nvim_create_augroup('ImeAutoFocus', { clear = true })
    vim.api.nvim_create_autocmd('FocusGained', {
      group = group,
      callback = function()
        if not ime_auto.is_enabled() then
          return
        end

        local utils = require('ime-auto.utils')
        if not utils.is_normal_mode() then
          return
        end

        local ok, status = pcall(ime_auto.ime.get_status)
        if ok and status then
          ime_auto.ime.off()
        end
      end,
    })
  end,
}
