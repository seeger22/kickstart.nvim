return {
  { -- PDFs in nvim: rendered pages via snacks. `o` hands the file to Sioyek
    -- for real reading (figures, search, two-page). Note its buffer maps:
    -- n/p = next/prev page, z/q = zoom in/out, e = reset zoom.
    'r-pletnev/pdfreader.nvim',
    lazy = false,
    dependencies = { 'folke/snacks.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      require('pdfreader').setup()
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*.pdf',
        callback = function(args)
          vim.keymap.set('n', 'o', function()
            vim.system { 'open', '-a', 'sioyek', vim.api.nvim_buf_get_name(args.buf) }
          end, { buffer = args.buf, desc = 'Open PDF in Sioyek' })
        end,
      })
    end,
  },
}
