-- Molten.nvim

return {
   {
      -- Molten enables interactive development in Neovim using Jupyter kernels
      -- For information on which languages are supported see https://github.com/jupyter/jupyter/wiki/Jupyter-kernels
      'benlubas/molten-nvim',
      version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
      dependencies = { '3rd/image.nvim' },
      build = ':UpdateRemotePlugins',
      init = function()
         vim.g.molten_image_provider = 'image.nvim'
         vim.g.molten_output_win_max_height = 20
      end,
      config = function()
         vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>', { silent = true, desc = '[M]olten [I]nit' })
         vim.keymap.set('n', '<localleader>dl', function()
            vim.cmd 'MoltenEvaluateLine'
         end, { desc = '[D]o [L]ine' })
         vim.keymap.set(
            'v',
            '<localleader>e',
            ':<C-u>MoltenEvaluateVisual<CR>gv<ESC>',
            { silent = true, desc = 'Molten [E]val Selection' }
         )
         vim.keymap.set(
            'n',
            '<localleader>e',
            ':MoltenEvaluateOperator<CR>',
            { silent = true, desc = 'Molten [E]val Motion' }
         )
         vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>', { silent = true, desc = '[M]olten [D]elete Cell' })
         vim.keymap.set(
            'n',
            '<localleader>ma',
            ':MoltenReevaluateAll<CR>',
            { silent = true, desc = '[M]olten [R]e-Evaluate All Cells' }
         )
         vim.keymap.set(
            'n',
            '<localleader>mr',
            ':MoltenReevaluateCell<CR>',
            { silent = true, desc = '[M]olten [R]e-Evaluate Cell' }
         )
         vim.keymap.set(
            'n',
            '<localleader>mR',
            ':MoltenRestart<CR>',
            { silent = true, desc = '[M]olten [R]estart Kernel' }
         )
         vim.keymap.set(
            'n',
            '<localleader>mo',
            ':noautocmd MoltenEnterOutput<CR>',
            { silent = true, desc = '[M]olten Enter [O]utput' }
         )
         vim.keymap.set(
            'n',
            '<localleader>mh',
            ':MoltenHideOutput<CR>',
            { silent = true, desc = '[M]olten [H]ide Output' }
         )
      end,
   },
   {
      -- NOTE: For iterm2 support you may have to adjust the plugin slightly like this issue
      -- https://github.com/3rd/image.nvim/issues/80
      '3rd/image.nvim',
      opts = {
         backend = 'ueberzug', -- whatever backend you would like to use
         max_width = 100,
         max_height = 12,
         max_height_window_percentage = math.huge,
         max_width_window_percentage = math.huge,
         window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
         window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
      },
      config = function()
         -- Add luarocks 5.1 packages to the nvim package path
         package.path = package.path .. ';' .. vim.fn.expand '$HOME' .. '/.luarocks/share/lua/5.1/?/init.lua;'
         package.path = package.path .. ';' .. vim.fn.expand '$HOME' .. '/.luarocks/share/lua/5.1/?.lua;'
      end,
   },
   {
      -- Uses molten to provide a notebook like experience for non-notebook files in Neovim
      'GCBallesteros/NotebookNavigator.nvim',
      dependencies = {
         -- "akinsho/toggleterm.nvim", -- alternative repl provider
         'benlubas/molten-nvim',
         'echasnovski/mini.nvim',
      },
      event = 'VeryLazy',

      config = function()
         local nn = require 'notebook-navigator'
         nn.setup {
            cell_markers = {
               python = '# COMMAND',
            },
            syntax_highlight = true,
         }

         vim.keymap.set('n', '<localleader>X', nn.run_cell, { desc = 'Run [C]ell' })
         vim.keymap.set('n', '<localleader>x', nn.run_and_move, { desc = 'Run and [M]ove' })
         vim.keymap.set('n', ']h', function()
            nn.move_cell 'd'
         end, { desc = 'Move [D]own a Cell' })
         vim.keymap.set('n', '[h', function()
            nn.move_cell 'u'
         end, { desc = 'Move [U]p a Cell' })
      end,
   },
   -- {
   --    'Vigemus/iron.nvim',
   --    config = function()
   --       local iron = require 'iron.core'
   --
   --       iron.setup {
   --          config = {
   --             -- Whether a repl should be discarded or not
   --             scratch_repl = true,
   --             close_window_on_exit = true,
   --             -- Your repl definitions come here
   --             repl_definition = {
   --                fish = {
   --                   -- Can be a table or a function that
   --                   -- returns a table (see below)
   --                   command = { 'fish' },
   --                },
   --                python = {
   --                   -- FIXME: Try to fetch the local python environment like in molten
   --                   command = { 'python3' },
   --                },
   --                lua = {
   --                   command = { 'redbean' },
   --                },
   --             },
   --             -- How the repl window will be displayed
   --             -- See below for more information
   --             repl_open_cmd = require('iron.view').split.botright.botright(0.2),
   --          },
   --          ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
   --       }
   --
   --       -- iron also has a list of commands, see :h iron-commands for all available commands
   --       vim.keymap.set('n', '<localleader>rs', ':IronRepl<CR>', { desc = '[R]epl [S]tart' })
   --       vim.keymap.set('n', '<localleader>rr', ':IronRestart<CR>', { desc = '[R]epl [R]estart' })
   --       vim.keymap.set('n', '<localleader>rf', ':IronFocus<CR>', { desc = '[R]epl [F]ocus' })
   --       vim.keymap.set('n', '<localleader>rh', ':IronHide<CR>', { desc = '[R]epl [H]ide' })
   --       vim.keymap.set('n', '<localleader>rl', require('iron').core.send_line, { desc = '[R]epl Eval [L]ine' })
   --       vim.keymap.set('v', '<localleader>r', function()
   --          local core = require 'iron.core'
   --          local lines = core.mark_visual()
   --          ---@diagnostic disable-next-line: undefined-global
   --          table.insert(lines, '\n')
   --          core.send(nil, lines)
   --       end, { desc = '[R]epl Eval (Visual)' })
   --    end,
   -- },
}
