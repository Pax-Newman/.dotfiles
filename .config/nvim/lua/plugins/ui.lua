local header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

local starter = require "mini.starter"
local config = {
   header = header,
   items = {
      -- TODO: Create starter actions
      {
         name = "Search",
         action = function()
            require("telescope.builtin").find_files {
               find_command = { "rg", "--files", "--hidden", "--iglob", "!.git", "--iglob", "!.venv" },
            }
         end,
         section = "",
      },
      {
         name = "Chat",
         action = function()
            -- TODO: Check if there's a way to open a fullscreen chat
            vim.cmd "CodeCompanionChat"
         end,
         section = "",
      },
   },
   footer = "",
   content_hooks = {
      starter.gen_hook.aligning("center", "center"),
      starter.gen_hook.adding_bullet(),
   },
}
starter.setup(config)

return {
   {
      -- Set lualine as statusline
      "https://github.com/nvim-lualine/lualine.nvim",
      config = function()
         -- See `:help lualine.txt`
         require("lualine").setup {
            options = {
               icons_enabled = true,
               theme = "seoul256",
               component_separators = "|",
               section_separators = { left = "", right = "" },
            },
            sections = {
               lualine_a = {
                  { "mode", separator = { left = "" }, right_padding = 2 },
               },
               lualine_b = { "filename", "branch" },
               lualine_c = {},
               lualine_x = {},
               -- TODO: Consider renabling this
               lualine_y = {
                  -- require("molten.status").kernels,
                  "filetype",
                  "progress",
               },
               lualine_z = {
                  { "location", separator = { right = "" }, left_padding = 2 },
               },
            },
            inactive_sections = {
               lualine_a = { "filename" },
               lualine_b = {},
               lualine_c = {},
               lualine_x = {},
               lualine_y = {},
               lualine_z = { "location" },
            },
            tabline = {},
            extensions = {},
         }
         vim.o.laststatus = 3
      end,
   },
}
