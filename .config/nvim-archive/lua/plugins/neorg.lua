local packages = {
   {
      'nvim-neorg/neorg',
      dependencies = { 'luarocks.nvim' },
      -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
      lazy = false,
      -- Pin Neorg to the latest stable release
      version = '*',
      opts = {
         load = {
            ['core.defaults'] = {},
            ['core.concealer'] = {},
            ['core.dirman'] = {
               config = {
                  workspaces = {
                     notes = '~/notes',
                  },
                  default_workspace = 'notes',
               },
            },
         },
      },
   },
   {
      'vhyrro/luarocks.nvim',
      priority = 1000,
      config = true,
   },
}

packages = {}

return packages
