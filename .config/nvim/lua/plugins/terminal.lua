return {
   -- Integrated floating terminal

   {
      'numToStr/FTerm.nvim',
      config = function()
         require('FTerm').setup {
            border = 'rounded',
            dimensions = {
               height = 0.8,
               width = 0.7,
            },
         }
         -- Remap tabs back to their original behavior
         -- TODO: See if there's a better way of doing this
         vim.keymap.set('n', '<tab>', '<tab>')
         vim.keymap.set('v', '<tab>', '<tab>')
         vim.keymap.set('t', '<tab>', '<tab>')
         -- toggle term in normal mode
         vim.keymap.set('n', '<C-i>', '<CMD>lua require("FTerm").toggle()<CR>')
         -- toggle term in terminal mode
         vim.keymap.set('t', '<C-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
      end,
   },

   -- {
   --    'akinsho/nvim-toggleterm.lua',
   --
   --    keys = {
   --       -- Remap tabs back to their original behavior
   --       -- TODO: See if there's a better way of doing this
   --       { '<tab>', '<tab>', mode = 'n' },
   --       { '<tab>', '<tab>', mode = 'v' },
   --       { '<tab>', '<tab>', mode = 't' },
   --    },
   --
   --    opts = {
   --       open_mapping = [[<C-i>]],
   --       size = 20,
   --       hide_numbers = true,
   --       start_in_insert = true,
   --       persist_mode = true,
   --       close_on_exit = true,
   --       shell = vim.o.shell,
   --       direction = 'float',
   --       float_opts = {
   --          border = 'rounded',
   --          width = math.floor(vim.o.columns * 0.7),
   --          height = math.floor(vim.o.lines * 0.8),
   --       },
   --    },
   -- },
}
