-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Open tabular files (csv, xlsx, xlsm, xls) via visidata in a terminal.
-- On quit, return to the previous buffer (usually the oil buffer you came from),
-- or open oil at the file's directory.
local function open_in_terminal(cli, args)
  local file = vim.fn.fnamemodify(args.file, ':p')
  local prev = vim.fn.bufnr('#')

  vim.cmd('bwipeout! ' .. args.buf)
  vim.cmd('terminal ' .. cli .. ' ' .. vim.fn.shellescape(file))
  local term_buf = vim.api.nvim_get_current_buf()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = 'no'
  vim.cmd 'startinsert'

  vim.api.nvim_create_autocmd('TermClose', {
    buffer = term_buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if prev ~= -1 and vim.api.nvim_buf_is_valid(prev) then
          vim.cmd('buffer ' .. prev)
        else
          vim.cmd('Oil ' .. vim.fn.fnameescape(vim.fn.fnamemodify(file, ':h')))
        end
        if vim.api.nvim_buf_is_valid(term_buf) then
          vim.cmd('bwipeout! ' .. term_buf)
        end
      end)
    end,
  })
end

vim.api.nvim_create_autocmd('BufReadCmd', {
  pattern = { '*.csv', '*.xlsx', '*.xlsm', '*.xls' },
  callback = function(args) open_in_terminal('vd', args) end,
})

-- Treesitter-based folding, JSON only. The general case is left off in the
-- nvim-treesitter config below so other filetypes keep foldmethod=manual.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'json',
  callback = function(args)
    vim.wo.foldmethod = 'expr'
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldlevel = 99

    vim.keymap.set('n', '<CR>', function()
      return vim.fn.foldlevel(vim.fn.line('.')) > 0 and 'za' or '<CR>'
    end, { buffer = args.buf, expr = true, desc = 'Toggle fold under cursor' })
  end,
})
