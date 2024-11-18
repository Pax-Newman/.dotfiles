local header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

return {
   {
      'echasnovski/mini.starter',
      event = 'VimEnter',
      opts = function()
         local starter = require 'mini.starter'
         local config = {
            header = header,
            items = {
               {
                  name = 'Get Started',
                  action = function()
                     require('telescope.builtin').find_files {
                        find_command = { 'rg', '--files', '--hidden', '--iglob', '!.git', '--iglob', '!.venv' },
                     }
                  end,
                  section = '',
               },
            },
            footer = '',
            content_hooks = {
               starter.gen_hook.aligning('center', 'center'),
               starter.gen_hook.adding_bullet(),
            },
         }
         return config
      end,
      config = function(_, opts)
         local starter = require 'mini.starter'
         starter.setup(opts)
      end,
   },
}
