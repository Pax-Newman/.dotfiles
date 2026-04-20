pack = vim.pack

-- pack.add "https://github.com/rose-pine/neovim"

return {
   {
      "https://codeberg.org/evergarden/nvim.git",
      name = "evergarden",
      config = function()
         require("evergarden").setup {
            theme = {
               variant = "winter", -- 'winter'|'fall'|'spring'|'summer'
               accent = "green",
            },
            editor = {
               transparent_background = true,
               sign = { color = "none" },
               float = {
                  color = "mantle",
                  invert_border = false,
               },
               completion = {
                  color = "surface0",
               },
            },
         }
      end,
   },
   {
      "https://github.com/rose-pine/neovim",
      config = function()
         require("rose-pine").setup {
            variant = "moon", -- 'auto'|'main'|'moon'|'dawn'
         }
      end,
   },
   {
      "https://github.com/ember-theme/nvim",
      name = "ember",
      config = function()
         require("ember").setup {
            variant = "ember", -- "ember" | "ember-soft" | "ember-light"
         }
         vim.cmd "colorscheme ember"
      end,
   },
}
