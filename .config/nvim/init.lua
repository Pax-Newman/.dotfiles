-- [[ Add Mise to PATH ]]

vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

-- [[ Enable Experimental Fast Package Loader ]]
vim.loader.enable()

-- [[ Load Options ]]
require "settings.options"

-- [[ Load LSP Config ]]
require "settings.lsp"

-- [[ Load Autocommands ]]
require "settings.autocommands"

-- [[ Configure Netrw ]]
require "settings.netrw"

-- [[ Install and configure plugins ]]

---@class PluginSpec
---@field [1] string Source repository to fetch the plugin from
---@field name string? How nvim should refer to this plugin
---@field version (string | vim.VersionRange)? What version/branch to pull
---@field config (fun(): table)? This runs on startup to configure the plugin
---@field enabled (boolean | fun(): boolean)?
---@field on_install (fun(data: table): nil)? Callback that runs when the plugin is installed
---@field on_update (fun(data: table): nil)? Callback that runs when the plugin is updated
---@field on_delete (fun(data: table): nil)? Callback that runs when the plugin is deleted
---@field build (fun(data: table): nil)? Callback that runs when the plugin is installed or updated;

---Installs and loads an array of plugin definiions
---@param plugins PluginSpec[]
local function load_plugins(plugins)
   for _, def in ipairs(plugins) do
      -- Check if any plugins are disabled and skip them
      local enabled_type = type(def.enabled)
      local enabled = true
      if enabled_type == "function" then
         enabled = def.enabled()
      elseif enabled_type == "boolean" then
         enabled = def.enabled
      end

      if not enabled then
         goto continue
      end

      -- Install & load plugins
      local data =
         { on_update = def.on_update, on_install = def.on_install, on_delete = def.on_delete, build = def.build }
      vim.pack.add { { src = def[1], name = def.name, data = data } }

      if def.config ~= nil then
         def.config()
      end
      ::continue::
   end
end

-- Configure plugin callbacks for package events
vim.api.nvim_create_autocmd("PackChanged", {
   desc = "execute plugin callbacks",
   callback = function(event)
      local data = event.data or {}
      local kind = data.kind or "" -- "install"|"update"|"delete"

      -- possible callbacks: on_install, on_update, on_delete
      local on_callback = vim.tbl_get(data, "spec", "data", "on_" .. kind)

      local build_callback
      if kind == "install" or kind == "update" then
         build_callback = vim.tbl_get(data, "spec", "data", "build")
      end

      local callbacks = { on_callback, build_callback }

      for _, callback in ipairs(callbacks) do
         if type(callback) ~= "function" then
            goto continue
         end

         vim.notify("Calling callback on " .. data.spec.name)

         local ok, err = pcall(callback, data)
         if not ok then
            vim.notify(err, vim.log.levels.ERROR)
         end

         ::continue::
      end
   end,
})

-- Load generic plugins and depednencies
load_plugins {
   { -- NOTE: This is going to be archived
      "https://github.com/nvim-lua/plenary.nvim",
   },
   { -- Load mini.nvim to be configured in other parts of the config
      "https://github.com/nvim-mini/mini.nvim",
   },
}

load_plugins(require "plugins.general")

load_plugins(require "plugins.colors")
vim.cmd.colorscheme "evergarden"

load_plugins(require "plugins.ui")

load_plugins(require "plugins.ai")

load_plugins(require "plugins.completion")

load_plugins(require "plugins.lsp")

-- [[ Load Custom Plugins and Code ]]

require "custom"

-- [[ Load Keymaps ]]

require "settings.keymaps"
