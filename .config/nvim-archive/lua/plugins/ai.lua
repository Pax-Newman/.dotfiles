return {
   -- Copilot Support
   {
      'zbirenbaum/copilot.lua',
      cmd = 'Copilot',
      -- event = 'InsertEnter', -- Starts Copilot when entering insert mode if left uncommented
      opts = {
         suggestion = {
            enabled = true,
            auto_trigger = true,
            debounce = 75,
            keymap = {
               -- Accept the suggestion
               -- (M- is the modifier aka alt or option)
               accept = '<M-l>',
               accept_word = false,
               accept_line = false,
               -- Cycle through suggestions
               next = '<M-j>',
               prev = '<M-k>',
               dismiss = '<C-]>',
            },
         },
         server_opts_overrides = {
            trace = 'verbose',
            settings = {
               advanced = {
                  inlineSuggestCount = 3, -- #completions for getCompletions
               },
            },
         },
      },
   },

   {
      'olimorris/codecompanion.nvim',
      opts = {
         -- strategies = {
         --
         -- },
         -- adapters = {
         --
         -- },
      },
      dependencies = {
         'nvim-lua/plenary.nvim',
         'nvim-treesitter/nvim-treesitter',
      },
      keys = {
         { '<leader>ac', '<cmd>CodeCompanionChat<CR>i', '[A]I [C]hat' },
         { '<leader>ai', '<cmd>CodeCompanion<CR>', 'Use [A]I [I]nline' },
         { '<leader>ai', '<cmd>CodeCompanion<CR>', 'Use [A]I [I]nline', mode = 'v' },
         { '<leader>sa', '<cmd>CodeCompanionActions<CR>', '[S]earch [A]I actions' },
      },
   },
}
