vim.keymap.set('n', '<localleader>mi', function()
   local venv = os.getenv 'VIRTUAL_ENV'
   if venv ~= nil then
      -- in the form of /home/USERNAME/.virtualenvs/VENV_NAME
      venv = string.match(venv, '/.+/(.+)')
      vim.cmd(('MoltenInit %s'):format(venv))
   else
      vim.cmd 'MoltenInit python3'
   end
end, { desc = '[M]olten [I]nit (python3)', silent = true })
