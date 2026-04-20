return {
   {
      'quarto-dev/quarto-nvim',

      ft = 'quarto',

      dependencies = {
         'jmbuhr/otter.nvim',
      },

      opts = {
         debug = false,
         closePreviewOnExit = true,
         lspFeatures = {
            enabled = true,
            chunks = 'curly',
            languages = { 'r', 'python', 'julia', 'bash', 'html' },
            diagnostics = {
               enabled = true,
               triggers = { 'BufWritePost' },
            },
            completion = {
               enabled = true,
            },
         },
         codeRunner = {
            enabled = true,
            default_method = 'molten', -- 'molten' or 'slime'
            ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
            -- Takes precedence over `default_method`
            never_run = { 'yaml' }, -- filetypes which are never sent to a code runner
         },
         keymap = {
            -- set whole section or individual keys to `false` to disable
            hover = 'K',
            definition = 'gd',
            type_definition = 'gD',
            rename = '<leader>rn',
            format = '<leader>f',
            references = 'gr',
         },
      },
      config = function(_, opts)
         require('quarto').setup(opts)
         local runner = require 'quarto.runner'

         vim.keymap.set('n', '<localleader>x', runner.run_cell, { desc = 'E[X]ecute cell', silent = true })
         vim.keymap.set('n', '<localleader>rb', runner.run_below, { desc = '[R]un cell and below', silent = true })
      end,
   },
   -- for lsp features in code cells / embedded code
   'jmbuhr/otter.nvim',
   dev = false,
   dependencies = {
      {
         'neovim/nvim-lspconfig',
         'nvim-treesitter/nvim-treesitter',
         'hrsh7th/nvim-cmp',
      },
   },
   opts = {
      buffers = {
         set_filetype = true,
         write_to_disk = false,
      },
      handle_leading_whitespace = true,
   },
}
