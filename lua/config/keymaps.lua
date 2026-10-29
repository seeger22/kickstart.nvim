-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
-- See :help vim.diagnostic.Opts
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = { float = true },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Copy current file path to clipboard
vim.keymap.set('n', '<leader>yp', function()
  local path = vim.fn.expand '%:p'
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path)
end, { desc = '[Y]ank file [P]ath' })

-- <leader>n / <leader>p: cycle to the next/previous file with the same extension
-- in the current file's directory, replacing the current buffer.
-- Sorting mirrors oil's natural_order: each run of digits is prefixed with its own
-- length so a plain string sort stays number-aware (foo-2 before foo-10, not after).
local function natural_key(name)
  return (name:gsub('0*(%d+)', function(int) return string.format('%03d%s', #int, int) end))
end
local function cycle_file(delta)
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  if file == '' then return end
  local dir = vim.fn.fnamemodify(file, ':h')
  local ext = (file:lower():match('%.([^%.]+)$')) or ''
  if ext == '' then return end
  local siblings = vim.tbl_filter(
    function(name) return (name:lower():match('%.([^%.]+)$')) == ext end,
    vim.fn.readdir(dir) or {}
  )
  local keys = {}
  for _, name in ipairs(siblings) do keys[name] = natural_key(name) end
  table.sort(siblings, function(a, b) return keys[a] < keys[b] end)
  if #siblings <= 1 then return end
  local current = vim.fn.fnamemodify(file, ':t')
  local idx = 1
  for i, name in ipairs(siblings) do if name == current then idx = i break end end
  local next_name = siblings[((idx - 1 + delta) % #siblings) + 1]
  vim.cmd('edit ' .. vim.fn.fnameescape(dir .. '/' .. next_name))
  vim.cmd('bwipeout! ' .. buf)
end
vim.keymap.set('n', '<leader>n', function() cycle_file(1) end, { desc = '[N]ext file in dir (same ext)' })
vim.keymap.set('n', '<leader>p', function() cycle_file(-1) end, { desc = '[P]revious file in dir (same ext)' })
