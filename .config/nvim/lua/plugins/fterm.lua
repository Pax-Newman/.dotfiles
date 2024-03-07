return {
  -- Integrated floating terminal

  {
    'numToStr/FTerm.nvim',
    config = function ()
      require('FTerm').setup {
        border = 'rounded',
        dimensions = {
          height = 0.8,
          width = 0.7,
        },
      }
      -- Remap tabs back to their original behavior
      -- TODO: See if there's a better way of doing this
      vim.keymap.set('n', '<tab>', '<tab>')
      vim.keymap.set('v', '<tab>', '<tab>')
      vim.keymap.set('t', '<tab>', '<tab>')
      -- toggle term in normal mode
      vim.keymap.set('n', '<C-i>', '<CMD>lua require("FTerm").toggle()<CR>')
      -- toggle term in terminal mode
      vim.keymap.set('t', '<C-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
    end
  },
}
