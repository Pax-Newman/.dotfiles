-- Molten.nvim

return {
   {
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
         vim.keymap.set('v', '<localleader>e', ':<C-u>MoltenEvaluateVisual<CR>gv<ESC>', { silent = true, desc = '[E]val selection' })
         vim.keymap.set('n', '<localleader>e', ':MoltenEvaluateOperator<CR>', { silent = true, desc = '[E]val operator selection' })
         vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>', { silent = true, desc = '[M]olten [D]elete Cell' })
         vim.keymap.set('n', '<localleader>ma', ':MoltenReevaluateAll<CR>', { silent = true, desc = '[M]olten [R]e-Evaluate All Cells' })
         vim.keymap.set('n', '<localleader>mr', ':MoltenReevaluateCell<CR>', { silent = true, desc = '[M]olten [R]e-Evaluate Cell' })
      end,
   },
   {
      -- see the image.nvim readme for more information about configuring this plugin
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
}
