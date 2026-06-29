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
         require("codecompanion").setup {
            adapters = {
               http = {
                  llama = function()
                     return require("codecompanion.adapters").extend("openai_compatible", {
                        formatted_name = "Llama",
                        env = {
                           url = "http://localhost:8080",
                           api_key = "llama",
                           chat_url = "/v1/chat/completions",
                        },
                        schema = {
                           model = {
                              default = "unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q4_K_S",
                           },
                        },
                     })
                  end,
               },
               acp = {
                  maki = function()
                     local helpers = require "codecompanion.adapters.acp.helpers"
                     return {
                        name = "maki",
                        formatted_name = "Maki",
                        type = "acp",
                        roles = {
                           llm = "assistant",
                           user = "user",
                        },
                        commands = {
                           default = {
                              "maki",
                              "acp",
                           },
                        },
                        defaults = {
                           mcpServers = {},
                           timeout = 20000, -- 20 seconds
                        },
                        parameters = {
                           protocolVersion = 1,
                           clientCapabilities = {
                              fs = { readTextFile = true, writeTextFile = true },
                           },
                           clientInfo = {
                              name = "CodeCompanion.nvim",
                              version = "1.0.0",
                           },
                        },
                        handlers = {
                           setup = function(self)
                              return true
                           end,
                           auth = function(self)
                              return true
                           end,
                           form_messages = function(self, messages, capabilities)
                              return helpers.form_messages(self, messages, capabilities)
                           end,
                           on_exit = function(self, code) end,
                        },
                     }
                  end,
               },
            },
         }

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
