return {
  'karb94/neoscroll.nvim',
  config = function()
    local neoscroll = require 'neoscroll'
    local keymap = {
      ['C-b'] = function()
        neoscroll.ctrl_b { duration = 350 }
      end,
      ['C-f'] = function()
        neoscroll.ctrl_f { duration = 350 }
      end,
      ['PageUp'] = function()
        neoscroll.ctrl_b { duration = 50 }
      end,
      ['PageDown'] = function()
        neoscroll.ctrl_f { duration = 50 }
      end,

      ['C-y'] = function()
        neoscroll.scroll(-0.1, { move_cursor = false, duration = 50 })
      end,
      ['C-e'] = function()
        neoscroll.scroll(0.1, { move_cursor = false, duration = 50 })
      end,

      ['zt'] = function()
        neoscroll.zt { half_win_duration = 150 }
      end,
      ['zz'] = function()
        neoscroll.zz { half_win_duration = 150 }
      end,
      ['zb'] = function()
        neoscroll.zb { half_win_duration = 150 }
      end,
    }
    local modes = { 'n', 'v', 'x' }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
    neoscroll.setup {
      performance_mode = true,
      duration = 50,

      mappings = {
        '<C-u>',
        '<C-d>',
      },
    }
  end,
}
