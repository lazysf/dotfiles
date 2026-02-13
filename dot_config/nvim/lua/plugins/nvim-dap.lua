return {
  {
    'rcarriga/nvim-dap-ui',
    lazy = true,
    config = function()
      require('dapui').setup()
    end,
  },
  { 'nvim-neotest/nvim-nio', lazy = true },
  {
    'theHamsta/nvim-dap-virtual-text',
    lazy = true,
    config = function()
      require('nvim-dap-virtual-text').setup()
    end,
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    lazy = false,
    opts = {
      ensure_installed = {
        'python',
        'delve',
        'codelldb',
      },
      automatic_installation = true,
      handlers = {},
    },
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    lazy = false,
    opts = {
      ensure_installed = {
        'js-debug-adapter',
        'bash-debug-adapter',
      },
      run_on_start = true,
      start_delay = 0,
    },
  },
  {
    'mxsdev/nvim-dap-vscode-js',
    lazy = false,
  },
  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        mode = 'n',
        desc = 'DAP toggle breakpoint',
      },
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        mode = 'n',
        desc = 'DAP continue',
      },
      {
        '<leader>dn',
        function()
          require('dap').step_over()
        end,
        mode = 'n',
        desc = 'DAP step over',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        mode = 'n',
        desc = 'DAP step into',
      },
      {
        '<leader>do',
        function()
          require('dap').step_out()
        end,
        mode = 'n',
        desc = 'DAP step out',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.toggle()
        end,
        mode = 'n',
        desc = 'DAP REPL toggle',
      },
      {
        '<leader>du',
        function()
          require('dapui').toggle()
        end,
        mode = 'n',
        desc = 'DAP UI toggle',
      },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      local language_setups = {
        'dap.python',
        'dap.rust',
        'dap.go',
        'dap.javascript',
        'dap.shell',
      }
      for _, module_name in ipairs(language_setups) do
        local ok, setup = pcall(require, module_name)
        if ok and type(setup) == 'function' then
          setup(dap)
        else
          vim.notify('DAP設定の読み込みに失敗: ' .. module_name, vim.log.levels.WARN)
        end
      end

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
}
