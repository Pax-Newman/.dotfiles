return {
   {
      'mistricky/codesnap.nvim',
      build = 'make',
      version = '^1',
      lazy = true,
      cmd = { 'CodeSnap', 'CodeSnapSave' },
      opts = {
         -- Where to save the snapshots with CodeSnapSave
         save_path = vim.fn.expand '$HOME/Pictures/CodeSnaps',

         -- Displays the file path in the snapshot
         has_breadcrums = true,

         watermark = '',
      },
   },
}
