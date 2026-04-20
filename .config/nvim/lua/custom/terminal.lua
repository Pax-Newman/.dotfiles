-- Terminal
-- Creates and manages floating terminals

---@class WindowSpec
---@field buffer integer The code of the terminal's buffer
---@field window integer The code of the terminal's window

---@class TermOpts
---@field name string? The unique name of the terminal
---@field buffer integer? The code of the terminal's buffer
---@field cmd string? Command to run on startup

---@class TermSpec
---@field name string The unique name of the terminal
---@field buffer integer The code of the terminal's buffer
---@field window integer The code of the terminal's window
---@field cmd string? Command to run on startup

---@class ModuleState
---@field terminals { string: TermSpec }
---@field active_terminal string?

local M = {}

---Returns all active terminals
---@return { string: TermSpec }
M.get_terminals = function()
   if vim.g.Terminal ~= nil then
      return vim.g.Terminal.terminals
   end
   error "Error fetching active terminals. No active state"
end

---Returns a terminal by name
---@param name string The terminal to fetch
---@return TermSpec?
M.get_terminal = function(name)
   return M.get_terminals()[name]
end

---Sets a terminal in the module state
---@param spec TermSpec
local _set_terminal = function(spec)
   local state = vim.g.Terminal
   state.terminals[spec.name] = spec
   vim.g.Terminal = state
end

---Removes a terminal from the module state
---@param name string
local _drop_terminal = function(name)
   if M.get_terminal(name) == nil then
      vim.notify('Tried to drop terminal "' .. name .. "\" but it doesn't exist", vim.log.levels.DEBUG)
   end
   local state = vim.g.Terminal
   state.terminals[name] = nil
   vim.g.Terminal = state
end

---Gets the active terminal or nil if there is none
---@return TermSpec?
M.get_active_terminal = function()
   local active = vim.g.Terminal.active_terminal
   if active ~= nil then
      return M.get_terminal(active)
   end
   return nil
end

---Sets the active terminal in the module state
---@param name string?
---@return TermSpec?
local _set_active_terminal = function(name)
   local state = vim.g.Terminal
   state.active_terminal = name
   vim.g.Terminal = state
   if name ~= nil then
      return M.get_terminal(name)
   end
end

---Creates a floating window in the middle of the screen
---@param buffer integer
---@return WindowSpec
M.create_window = function(buffer)
   -- TODO: Support options for things like
   -- border type
   -- window position
   -- window size

   local max_height = vim.o.lines
   local max_width = vim.o.columns

   local height = math.floor(max_height * 0.5)
   local width = math.floor(max_width * 0.5)

   local win_buf = buffer or vim.api.nvim_create_buf(false, true)

   local win = vim.api.nvim_open_win(win_buf, true, {
      relative = "editor",
      height = height,
      width = width,
      col = (max_width - width) / 2,
      row = (max_height - height) / 2,
      border = "rounded",
   })

   return { buffer = win_buf, window = win }
end

---Creates a floating terminal
---@param opts TermOpts
---@return TermSpec
M.create_terminal = function(opts)
   local options = opts or {}

   if options.name ~= nil then
      if M.get_terminal(options.name) ~= nil then
         error("Terminal `" .. options.name .. "` already exists")
      end
   else
      options.name = string.format("%d", math.random(0, 1000000))
   end

   local winspec = M.create_window(options.buffer)

   vim.cmd.term(options.cmd)
   vim.cmd "startinsert"

   ---@type TermSpec
   local termspec = {
      name = options.name,
      buffer = winspec.buffer,
      window = winspec.window,
      cmd = options.cmd,
   }

   vim.api.nvim_create_autocmd({ "TermClose" }, {
      buffer = termspec.buffer,
      callback = function(_)
         vim.notify "Left terminal"
         local spec = M.get_terminal(termspec.name)
         M.close_terminal(spec)
      end,
   })
   vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
      buffer = termspec.buffer,
      callback = function(_)
         vim.notify "Hid terminal"
         local spec = M.get_terminal(termspec.name)
         M.hide_terminal(spec)
      end,
   })

   vim.keymap.set("n", "<Esc>", function()
      local spec = M.get_terminal(termspec.name)
      M.hide_terminal(spec)
   end, { buf = termspec.buffer })

   _set_terminal(termspec)

   return termspec
end

---Shows a terminal or toggles the active terminal
---@param name string
---@return TermSpec
M.show_terminal = function(name)
   local spec = M.get_terminal(name)

   if spec == nil then
      error(string.format('Tried setting terminal "%s" to active but it does not exist', name))
   end

   local active = M.get_active_terminal()
   if active ~= nil and active.name == name then
      vim.notify(string.format('Terminal " %s " is already active', name), vim.log.levels.DEBUG)
      return spec
   end

   if active ~= nil then
      M.hide_terminal(active)
   end

   _set_active_terminal(name)

   if not vim.api.nvim_win_is_valid(spec.window) then
      local winspec = M.create_window(spec.buffer)
      spec.window = winspec.window
      _set_terminal(spec)
   end
   vim.cmd "startinsert"

   return spec
end

---Hides and deactivates the terminal if its active
---@param spec TermSpec
---@return nil
M.hide_terminal = function(spec)
   if spec == nil then -- or vim.api.nvim_win_get_config(M.window).hide then
      vim.notify "No terminal to hide"
      return
   end

   vim.api.nvim_win_hide(spec.window)

   -- Safeguard to only deactivate the window if it hasn't been already
   local active = M.get_active_terminal()
   if active ~= nil and active.name == spec.name then
      _set_active_terminal(nil)
   end

   return spec
end

---Opens a terminal or creates one if it doesn't exist
---@param name string?
---@param opts TermOpts?
---@return TermSpec
M.open_terminal = function(name, opts)
   local options = opts or { name = name }

   if name == nil or M.get_terminal(name) == nil then
      local new_term = M.create_terminal(options)
      return M.show_terminal(new_term.name)
   else
      return M.show_terminal(name)
   end
end

---Closes a terminal and deletes its buffer and window
---@param spec TermSpec
---@return nil
M.close_terminal = function(spec)
   _drop_terminal(spec.name)
   vim.api.nvim_win_close(spec.window, true)
   vim.api.nvim_buf_delete(spec.buffer, { force = true })
end

---Sets up the module and initializes state
---@param opts any
M.setup = function(opts)
   ---@type ModuleState
   vim.g.Terminal = { terminals = {}, active_terminal = nil }
end

return M
