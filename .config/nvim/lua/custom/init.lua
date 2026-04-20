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
   term.open_terminal "Main"
end)
