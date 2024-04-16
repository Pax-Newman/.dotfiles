local function header()
   return [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]
end

return {
   {
      'echasnovski/mini.starter',
      event = 'VimEnter',
      opts = function()
         local starter = require 'mini.starter'
         local config = {
            header = header,
            items = {
               starter.sections.builtin_actions(),
               -- starter.sections.recent_files(10, false),
               starter.sections.recent_files(10, true),
            },
            footer = '',
         }
         return config
      end,
      config = function(_, opts)
         local starter = require 'mini.starter'
         starter.setup(opts)
      end,
   },
}
