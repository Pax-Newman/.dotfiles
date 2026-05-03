---Connects to the Godot LSP
---@param dispatchers vim.lsp.rpc.Dispatchers
---@param config vim.lsp.ClientConfig
---@return vim.lsp.rpc.PublicClient
local function start_server(dispatchers, config)
   -- Open a server pipe for the Godot editor to connect to
   -- This allows the editor to send commands to Neovim
   local is_server_running = vim.uv.fs_stat(config.root_dir .. "/server.pipe")
   if not is_server_running then
      vim.fn.serverstart(config.root_dir .. "/server.pipe")
   end

   -- Connect to the editor's built-in LSP
   local port = os.getenv "GDScript_Port" or "6005"
   return vim.lsp.rpc.connect("127.0.0.1", tonumber(port))(dispatchers)
end

---@type vim.lsp.Config
return {
   cmd = start_server,
   filetypes = { "gdscript" },
   root_markers = { "project.godot", ".git" },
}
