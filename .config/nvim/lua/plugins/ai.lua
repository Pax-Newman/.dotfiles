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
}
