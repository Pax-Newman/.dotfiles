-- [[ Setup Mini plugins ]]
require("mini.ai").setup { n_lines = 500 }
require("mini.surround").setup()

-- [[ Load general plugins ]]
return {
   {
      -- NOTE: This is archived
      "https://github.com/nvim-treesitter/nvim-treesitter",
      version = "main",
      build = function()
         vim.cmd "TSUpdate"
      end,

      config = function()
         -- ensure basic parser are installed
         local parsers = {
            "bash",
            "c",
            "diff",
            "html",
            "lua",
            "luadoc",
            "markdown",
            "markdown_inline",
            "query",
            "vim",
            "vimdoc",
            "python",
            "javascript",
            "fish",
         }
         require("nvim-treesitter").install(parsers)

         ---@param buf integer
         ---@param language string
         local function treesitter_try_attach(buf, language)
            -- check if parser exists and load it
            if not vim.treesitter.language.add(language) then
               return
            end
            -- enables syntax highlighting and other treesitter features
            vim.treesitter.start(buf, language)

            -- enables treesitter based folds
            -- for more info on folds see `:help folds`
            -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            -- vim.wo.foldmethod = 'expr'

            -- check if treesitter indentation is available for this language, and if so enable it
            -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
            local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

            -- enables treesitter based indentation
            if has_indent_query then
               vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
         end

         local available_parsers = require("nvim-treesitter").get_available()
         vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
               local buf, filetype = args.buf, args.match

               local language = vim.treesitter.language.get_lang(filetype)
               if not language then
                  return
               end

               local installed_parsers = require("nvim-treesitter").get_installed "parsers"

               if vim.tbl_contains(installed_parsers, language) then
                  -- enable the parser if it is installed
                  treesitter_try_attach(buf, language)
               elseif vim.tbl_contains(available_parsers, language) then
                  -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
                  require("nvim-treesitter").install(language):await(function()
                     treesitter_try_attach(buf, language)
                  end)
               else
                  -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
                  treesitter_try_attach(buf, language)
               end
            end,
         })
      end,
   },
   {
      "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
      version = "master",
   },

   { -- Adds git related signs to the gutter, as well as utilities for managing changes
      "https://github.com/lewis6991/gitsigns.nvim",
      config = function()
         require("gitsigns").setup {
            signs = {
               add = { text = "+" },
               change = { text = "~" },
               delete = { text = "_" },
               topdelete = { text = "‾" },
               changedelete = { text = "~" },
            },
         }
      end,
   },

   { -- Useful plugin to show you pending keybinds.
      "https://github.com/folke/which-key.nvim",

      config = function()
         require("which-key").setup {
            -- delay between pressing a key and opening which-key (milliseconds)
            delay = 0,
            icons = { mappings = vim.g.have_nerd_font },

            -- Document existing key chains
            spec = {
               { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
               { "<leader>t", group = "[T]oggle" },
               { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } }, -- Enable gitsigns recommended keymaps first
               { "gr", group = "LSP Actions", mode = { "n" } },

               -- TODO: see if old keychains still make sense
               -- { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
               -- { "<leader>d", group = "[D]ocument" },
               -- { "<leader>r", group = "[R]ename" },
               -- { "<leader>s", group = "[S]earch" },
               -- { "<leader>w", group = "[W]orkspace" },
               -- { "<leader>t", group = "[T]oggle" },
               -- { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
            },
         }
      end,
   },

   { -- If encountering errors, see telescope-fzf-native README for installation instructions
      "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
      build = function(data)
         vim.notify("Attempting to build telescope-fzf at: " .. data.path)
         local res = vim.system({ "make" }, { cwd = data.path }):wait()
         if res.code ~= 0 then
            vim.notify("Build failed with code " .. code .. " and err " .. res.stderr)
         end
      end,
   },
   { "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
   { -- Useful for getting pretty icons, but requires a Nerd Font.
      "https://github.com/nvim-tree/nvim-web-devicons",
      enabled = vim.g.have_nerd_font,
   },
   { -- Fuzzy Finder (files, lsp, etc)
      "https://github.com/nvim-telescope/telescope.nvim",
      -- Dependencies
      -- nvim-lua/plenary.nvim
      -- nvim-telescope/telescope-fzf-native.nvim
      -- nvim-telescope/telescope-ui-select.nvim
      -- nvim-tree/nvim-web-devicons

      -- By default, Telescope is included and acts as your picker for everything.

      -- If you would like to switch to a different picker (like snacks, or fzf-lua)
      -- you can disable the Telescope plugin by setting enabled to false and enable
      -- your replacement picker by requiring it explicitly (e.g. 'custom.plugins.snacks')

      -- Note: If you customize your config for yourself,
      -- it’s best to remove the Telescope plugin config entirely
      -- instead of just disabling it here, to keep your config clean.
      -- enabled = true,
      -- event = "VimEnter",
      config = function()
         -- Telescope is a fuzzy finder that comes with a lot of different things that
         -- it can fuzzy find! It's more than just a "file finder", it can search
         -- many different aspects of Neovim, your workspace, LSP, and more!
         --
         -- The easiest way to use Telescope, is to start by doing something like:
         --  :Telescope help_tags
         --
         -- After running this command, a window will open up and you're able to
         -- type in the prompt window. You'll see a list of `help_tags` options and
         -- a corresponding preview of the help.
         --
         -- Two important keymaps to use while in Telescope are:
         --  - Insert mode: <c-/>
         --  - Normal mode: ?
         --
         -- This opens a window that shows you all of the keymaps for the current
         -- Telescope picker. This is really useful to discover what Telescope can
         -- do as well as how to actually do it!

         -- [[ Configure Telescope ]]
         -- See `:help telescope` and `:help telescope.setup()`
         require("telescope").setup {
            defaults = {
               mappings = {
                  i = {
                     ["<C-j>"] = "move_selection_next",
                     ["<C-k>"] = "move_selection_previous",
                  },
               },
            },
            extensions = {
               ["ui-select"] = { require("telescope.themes").get_dropdown() },
            },
         }

         -- Enable Telescope extensions if they are installed
         pcall(require("telescope").load_extension, "fzf")
         pcall(require("telescope").load_extension, "ui-select")

         -- See `:help telescope.builtin`
         local builtin = require "telescope.builtin"
         vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
         vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
         vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
         vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
         vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
         vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
         vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
         vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
         vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
         vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
         vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

         -- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
         -- it is better explained there). This allows easily switching between pickers if you prefer using something else!
         vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
            callback = function(event)
               local buf = event.buf

               -- Find references for the word under your cursor.
               vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })

               -- Jump to the implementation of the word under your cursor.
               -- Useful when your language has ways of declaring types without an actual implementation.
               vim.keymap.set(
                  "n",
                  "gri",
                  builtin.lsp_implementations,
                  { buffer = buf, desc = "[G]oto [I]mplementation" }
               )

               -- Jump to the definition of the word under your cursor.
               -- This is where a variable was first declared, or where a function is defined, etc.
               -- To jump back, press <C-t>.
               vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })

               -- Fuzzy find all the symbols in your current document.
               -- Symbols are things like variables, functions, types, etc.
               vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Open Document Symbols" })

               -- Fuzzy find all the symbols in your current workspace.
               -- Similar to document symbols, except searches over your entire project.
               vim.keymap.set(
                  "n",
                  "gW",
                  builtin.lsp_dynamic_workspace_symbols,
                  { buffer = buf, desc = "Open Workspace Symbols" }
               )

               -- Jump to the type of the word under your cursor.
               -- Useful when you're not sure what type a variable is and you want to see
               -- the definition of its *type*, not where it was *defined*.
               vim.keymap.set(
                  "n",
                  "grt",
                  builtin.lsp_type_definitions,
                  { buffer = buf, desc = "[G]oto [T]ype Definition" }
               )
            end,
         })

         -- Override default behavior and theme when searching
         vim.keymap.set("n", "<leader>/", function()
            -- You can pass additional configuration to Telescope to change the theme, layout, etc.
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
               winblend = 10,
               previewer = false,
            })
         end, { desc = "[/] Fuzzily search in current buffer" })

         -- It's also possible to pass additional configuration options.
         --  See `:help telescope.builtin.live_grep()` for information about particular keys
         vim.keymap.set("n", "<leader>s/", function()
            builtin.live_grep {
               grep_open_files = true,
               prompt_title = "Live Grep in Open Files",
            }
         end, { desc = "[S]earch [/] in Open Files" })

         -- Shortcut for searching your Neovim configuration files
         vim.keymap.set("n", "<leader>sn", function()
            builtin.find_files { cwd = vim.fn.stdpath "config" }
         end, { desc = "[S]earch [N]eovim files" })
      end,
   },

   { -- Autoformat
      "https://github.com/stevearc/conform.nvim",
      config = function()
         require("conform").setup {
            notify_on_error = false,
            format_on_save = function(bufnr)
               -- Disable "format_on_save lsp_fallback" for languages that don't
               -- have a well standardized coding style. You can add additional
               -- languages here or re-enable it for the disabled ones.
               local disable_filetypes = { c = true, cpp = true }
               if disable_filetypes[vim.bo[bufnr].filetype] then
                  return nil
               else
                  return {
                     timeout_ms = 500,
                     lsp_format = "fallback",
                  }
               end
            end,
            formatters_by_ft = {
               lua = { "stylua" },
               json = { "jq" },
               swift = { "swift_format" },
               -- gdscript = { 'gdformat' },
               python = { "ruff_format" },
               -- You can use a sub-list to tell conform to run *until* a formatter is found.
               javascript = { { "prettierd", "prettier" } },
            },
            formatters = {
               stylua = {
                  command = "stylua",
                  inherit = true,
                  prepend_args = {
                     "--indent-type",
                     "Spaces",
                     "--indent-width",
                     "3",
                     "--call-parentheses",
                     "None",
                  },
               },
            },
         }
      end,
   },

   { -- Highlight todo, notes, etc in comments
      "https://github.com/folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
         require("todo-comments").setup { signs = false }
      end,
   },

   {
      "https://github.com/mistricky/codesnap.nvim",
      enabled = false,
      version = vim.version.range "2.x",
      config = function()
         require("codesnap").setup {
            -- Where to save the snapshots with CodeSnapSave
            save_path = vim.fn.expand "$HOME/Pictures/CodeSnaps",

            snapshot_config = {
               -- Remove watermark
               watermark = { content = "" },

               code_config = {
                  -- Displays the file path in the snapshot
                  breadcrumbs = { enable = true },
               },
            },
         }
      end,
   },
}
