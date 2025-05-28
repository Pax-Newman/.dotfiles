-- [[ Add Mise to PATH ]]

vim.env.PATH = vim.env.HOME .. '/.local/share/mise/shims:' .. vim.env.PATH

-- [[ Load Options ]]

require 'settings.options'

-- [[ Load Keymaps ]]

require 'settings.keymaps'

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`ini

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
   desc = 'Highlight when yanking (copying) text',
   group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
   callback = function()
      vim.highlight.on_yank()
   end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
   local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
   vim.fn.system {
      'git',
      'clone',
      '--filter=blob:none',
      '--branch=stable',
      lazyrepo,
      lazypath,
   }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins, you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({

   { import = 'plugins' },

   -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
   'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

   -- NOTE: Plugins can also be added by using a table,
   -- with the first argument being the link and the following
   -- keys can be used to configure plugin behavior/loading/etc.
   --
   -- Use `opts = {}` to force a plugin to be loaded.
   --
   --  This is equivalent to:
   --    require('Comment').setup({})

   -- "gc" to comment visual regions/lines
   { 'numToStr/Comment.nvim', opts = {} },

   -- Here is a more advanced example where we pass configuration
   -- options to `gitsigns.nvim`. This is equivalent to the following lua:
   --    require('gitsigns').setup({ ... })
   --
   -- See `:help gitsigns` to understand what the configuration keys do
   { -- Adds git related signs to the gutter, as well as utilities for managing changes
      'lewis6991/gitsigns.nvim',
      opts = {
         signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
         },
      },
   },

   -- NOTE: Plugins can also be configured to run lua code when they are loaded.
   --
   -- This is often very useful to both group configuration, as well as handle
   -- lazy loading plugins that don't need to be loaded immediately at startup.
   --
   -- For example, in the following configuration, we use:
   --  event = 'VimEnter'
   --
   -- which loads which-key before all the UI elements are loaded. Events can be
   -- normal autocommands events (`:help autocmd-events`).
   --
   -- Then, because we use the `config` key, the configuration only runs
   -- after the plugin has been loaded:
   --  config = function() ... end

   { -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VimEnter', -- Sets the loading event to 'VimEnter'

      opts = {
         icons = {
            -- set icon mappings to true if you have a Nerd Font
            mappings = vim.g.have_nerd_font,
            -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
            -- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
            keys = vim.g.have_nerd_font and {} or {
               Up = '<Up> ',
               Down = '<Down> ',
               Left = '<Left> ',
               Right = '<Right> ',
               C = '<C-…> ',
               M = '<M-…> ',
               D = '<D-…> ',
               S = '<S-…> ',
               CR = '<CR> ',
               Esc = '<Esc> ',
               ScrollWheelDown = '<ScrollWheelDown> ',
               ScrollWheelUp = '<ScrollWheelUp> ',
               NL = '<NL> ',
               BS = '<BS> ',
               Space = '<Space> ',
               Tab = '<Tab> ',
               F1 = '<F1>',
               F2 = '<F2>',
               F3 = '<F3>',
               F4 = '<F4>',
               F5 = '<F5>',
               F6 = '<F6>',
               F7 = '<F7>',
               F8 = '<F8>',
               F9 = '<F9>',
               F10 = '<F10>',
               F11 = '<F11>',
               F12 = '<F12>',
            },
         },

         -- Document existing key chains
         spec = {
            { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
            { '<leader>d', group = '[D]ocument' },
            { '<leader>r', group = '[R]ename' },
            { '<leader>s', group = '[S]earch' },
            { '<leader>w', group = '[W]orkspace' },
            { '<leader>t', group = '[T]oggle' },
            { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
         },
      },
   },

   -- NOTE: Plugins can specify dependencies.
   --
   -- The dependencies are proper plugin specifications as well - anything
   -- you do for a plugin at the top level, you can do for a dependency.
   --
   -- Use the `dependencies` key to specify the dependencies of a particular plugin

   { -- Fuzzy Finder (files, lsp, etc)
      'nvim-telescope/telescope.nvim',
      event = 'VimEnter',
      branch = '0.1.x',
      dependencies = {
         'nvim-lua/plenary.nvim',
         { -- If encountering errors, see telescope-fzf-native README for install instructions
            'nvim-telescope/telescope-fzf-native.nvim',

            -- `build` is used to run some command when the plugin is installed/updated.
            -- This is only run then, not every time Neovim starts up.
            build = 'make',

            -- `cond` is a condition used to determine whether this plugin should be
            -- installed and loaded.
            cond = function()
               return vim.fn.executable 'make' == 1
            end,
         },
         { 'nvim-telescope/telescope-ui-select.nvim' },

         -- Useful for getting pretty icons, but requires a Nerd Font.
         { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      },
      config = function()
         -- Telescope is a fuzzy finder that comes with a lot of different things that
         -- it can fuzzy find! It's more than just a "file finder", it can search
         -- many different aspects of Neovim, your workspace, LSP, and more!
         --
         -- The easiest way to use telescope, is to start by doing something like:
         --  :Telescope help_tags
         --
         -- After running this command, a window will open up and you're able to
         -- type in the prompt window. You'll see a list of help_tags options and
         -- a corresponding preview of the help.
         --
         -- Two important keymaps to use while in telescope are:
         --  - Insert mode: <c-/>
         --  - Normal mode: ?
         --
         -- This opens a window that shows you all of the keymaps for the current
         -- telescope picker. This is really useful to discover what Telescope can
         -- do as well as how to actually do it!

         -- [[ Configure Telescope ]]
         -- See `:help telescope` and `:help telescope.setup()`
         require('telescope').setup {
            -- You can put your default mappings / updates / etc. in here
            --  All the info you're looking for is in `:help telescope.setup()`
            --
            defaults = {
               mappings = {
                  i = {
                     ['<C-j>'] = 'move_selection_next',
                     ['<C-k>'] = 'move_selection_previous',
                  },
               },
            },
            -- pickers = {}
            extensions = {
               ['ui-select'] = {
                  require('telescope.themes').get_dropdown(),
               },
            },
         }

         -- Enable telescope extensions, if they are installed
         pcall(require('telescope').load_extension, 'fzf')
         pcall(require('telescope').load_extension, 'ui-select')

         -- See `:help telescope.builtin`
         local builtin = require 'telescope.builtin'
         vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
         vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
         vim.keymap.set('n', '<leader>sf', function()
            require('telescope.builtin').find_files {
               find_command = { 'rg', '--files', '--hidden', '--iglob', '!.git', '--iglob', '!.venv' },
            }
         end, { desc = '[S]earch [F]iles' })
         vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
         vim.keymap.set('n', '<leader>sw', function()
            -- Include hidden files but exclude .git
            require('telescope.builtin').grep_string {
               find_command = { 'rg', '--files', '--hidden', '--iglob', '!.git', '--iglob', '!.venv' },
            }
         end, { desc = '[S]earch current [W]ord' })
         vim.keymap.set('n', '<leader>sg', function()
            require('telescope.builtin').live_grep {
               find_command = { 'rg', '--files', '--hidden', '--iglob', '!.git', '--iglob', '!.venv' },
            }
         end, { desc = '[S]earch by [G]rep' })
         vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
         vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
         vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
         vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

         -- Slightly advanced example of overriding default behavior and theme
         vim.keymap.set('n', '<leader>/', function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
               winblend = 10,
               previewer = false,
            })
         end, { desc = '[/] Fuzzily search in current buffer' })

         -- Also possible to pass additional configuration options.
         --  See `:help telescope.builtin.live_grep()` for information about particular keys
         vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
               grep_open_files = true,
               prompt_title = 'Live Grep in Open Files',
            }
         end, { desc = '[S]earch [/] in Open Files' })

         -- Shortcut for searching your neovim configuration files
         vim.keymap.set('n', '<leader>sn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
         end, { desc = '[S]earch [N]eovim files' })
      end,
   },

   { -- Autoformat
      'stevearc/conform.nvim',
      opts = {
         notify_on_error = false,

         format_on_save = function(bufnr)
            -- Disable autoformat on certain filetypes
            local ignore_filetypes = { 'sql', 'java' }
            if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
               return
            end
            -- Disable with a global or buffer-local variable
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
               return
            end
            -- Disable autoformat for files in a certain path
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname:match '/node_modules/' then
               return
            end
            -- ...additional logic...
            return { timeout_ms = 500, lsp_fallback = true }
         end,

         formatters_by_ft = {
            lua = { 'stylua' },
            json = { 'jq' },
            swift = { 'swift_format' },
            -- gdscript = { 'gdformat' },
            -- Conform can also run multiple formatters sequentially
            -- python = { "isort", "black" },
            --
            -- You can use a sub-list to tell conform to run *until* a formatter
            -- is found.
            javascript = { { 'prettierd', 'prettier' } },
         },

         formatters = {
            stylua = {
               command = 'stylua',
               inherit = true,
               prepend_args = {
                  '--indent-type',
                  'Spaces',
                  '--indent-width',
                  '3',
                  '--call-parentheses',
                  'None',
               },
            },
         },
      },
      config = function(self, opts)
         require('conform').setup(opts)

         vim.api.nvim_create_user_command('FormatDisable', function(args)
            if args.bang then
               -- FormatDisable! will disable formatting just for this buffer
               vim.b.disable_autoformat = true
            else
               vim.g.disable_autoformat = true
            end
         end, {
            desc = 'Disable autoformat-on-save',
            bang = true,
         })
         vim.api.nvim_create_user_command('FormatEnable', function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
         end, {
            desc = 'Re-enable autoformat-on-save',
         })
      end,
   },

   -- Highlight todo, notes, etc in comments
   {
      'folke/todo-comments.nvim',
      event = 'VimEnter',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = { signs = false },
   },

   { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      event = 'VeryLazy',
      config = function()
         -- Better Around/Inside textobjects
         --
         -- Examples:
         --  - va)  - [V]isually select [A]round [)]paren
         --  - yinq - [Y]ank [I]nside [N]ext [']quote
         --  - ci'  - [C]hange [I]nside [']quote
         require('mini.ai').setup { n_lines = 500 }

         -- Add/delete/replace surroundings (brackets, quotes, etc.)
         --
         -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
         -- - sd'   - [S]urround [D]elete [']quotes
         -- - sr)'  - [S]urround [R]eplace [)] [']
         require('mini.surround').setup()
         -- ... and there is more!
         --  Check out: https://github.com/echasnovski/mini.nvim
      end,
   },

   -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
   -- init.lua. If you want these files, they are in the repository, so you can just download them and
   -- put them in the right spots if you want.

   -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for kickstart
   --
   --  Here are some example plugins that I've included in the kickstart repository.
   --  Uncomment any of the lines below to enable them (you will need to restart nvim).
   --
   -- require 'kickstart.plugins.debug',
   -- require 'kickstart.plugins.indent_line',

   -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
   --    This is the easiest way to modularize your config.
   --
   --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
   --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
   -- { import = 'custom.plugins' },
}, {
   ui = {
      -- If you have a Nerd Font, set icons to an empty table which will use the
      -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
      icons = vim.g.have_nerd_font and {} or {
         cmd = '⌘',
         config = '🛠',
         event = '📅',
         ft = '📂',
         init = '⚙',
         keys = '🗝',
         plugin = '🔌',
         runtime = '💻',
         require = '🌙',
         source = '📄',
         start = '🚀',
         task = '📌',
         lazy = '💤 ',
      },
   },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
