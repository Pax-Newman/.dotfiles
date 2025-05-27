return {
   { -- You can easily change to a different colorscheme.
      -- Change the name of the colorscheme plugin below, and then
      -- change the command in the config to whatever the name of that colorscheme is
      --
      -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`
      'rose-pine/neovim',
      lazy = false, -- make sure we load this during startup if it is your main colorscheme
      priority = 1000, -- make sure to load this before all the other start plugins
      variant = 'moon',
      name = 'rose-pine',
      config = function()
         -- Load the colorscheme here.
         -- Like many other themes, this one has different styles, and you could load
         -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
         vim.cmd.colorscheme 'rose-pine'

         -- You can configure highlights by doing something like
         vim.cmd.hi 'Comment gui=none'
      end,
   },

   {
      'everviolet/nvim',
      name = 'evergarden',
      priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
      opts = {
         theme = {
            variant = 'fall', -- 'winter'|'fall'|'spring'|'summer'
            accent = 'green',
         },
         editor = {
            transparent_background = false,
            sign = { color = 'none' },
            float = {
               color = 'mantle',
               invert_border = false,
            },
            completion = {
               color = 'surface0',
            },
         },
      },
   },
}
