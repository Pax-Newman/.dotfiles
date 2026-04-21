---Global function for debugging
---@param v any
---@return any
function P(v)
   -- TODO: Move this to a globals file
   print(vim.inspect(v))
   return v
end

-- [[ Creates and manages floating terminals ]]
require("custom.terminal").setup()

vim.keymap.set("n", "<C-i>", function()
   local term = require "custom.terminal"
   local term_data = term.open_terminal "Main"

   -- TODO: Find a way to map <Tab> and <C-i> so they're not the same key
   vim.keymap.set("t", "<C-i>", function()
      term.hide_terminal(term_data)
   end, { buf = term_data.buffer, desc = "Hide floating terminal" })
end, { desc = "Open floating terminal" })
