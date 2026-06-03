return {
   {
      "https://github.com/mason-org/mason.nvim",
      config = function()
         require("mason").setup {}
      end,
   },
   {
      "https://github.com/neovim/nvim-lspconfig",
   },

   {
      "https://github.com/mason-org/mason-lspconfig.nvim",
      config = function()
         require("mason-lspconfig").setup {
            automatic_enable = false,
         }
      end,
   },
}
