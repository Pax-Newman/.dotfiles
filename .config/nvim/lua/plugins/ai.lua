return {
   -- Copilot Support
   {
      "https://github.com/zbirenbaum/copilot.lua",
      config = function()
         require("copilot").setup {
            suggestion = {
               enabled = false,
               auto_trigger = false,
               debounce = 75,
               keymap = {
                  -- Accept the suggestion
                  -- (M- is the modifier aka alt or option)
                  accept = "<M-l>",
                  accept_word = false,
                  accept_line = false,
                  -- Cycle through suggestions
                  next = "<M-j>",
                  prev = "<M-k>",
                  dismiss = "<C-]>",
               },
            },
            server_opts_overrides = {
               trace = "verbose",
               settings = {
                  advanced = {
                     inlineSuggestCount = 3, -- #completions for getCompletions
                  },
               },
            },
         }
      end,
   },

   {
      "https://github.com/olimorris/codecompanion.nvim",
      -- Dependencies:
      -- "nvim-lua/plenary.nvim",
      -- "nvim-treesitter/nvim-treesitter",
      config = function()
         require("codecompanion").setup()

         local keys = {
            { "n", "<leader>ac", "<cmd>CodeCompanionChat<CR>i", "[A]I [C]hat" },
            { "n", "<leader>ai", "<cmd>CodeCompanion<CR>", "Use [A]I [I]nline" },
            { "n", "<leader>sa", "<cmd>CodeCompanionActions<CR>", "[S]earch [A]I actions" },
            -- TODO: Create a command for sending a function and all of its callsites to the AI
         }

         for _, keymap in ipairs(keys) do
            vim.keymap.set(keymap[1], keymap[2], keymap[3], { desc = keymap[4] })
         end
      end,
   },
}
