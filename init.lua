-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Skips default Netrw, use oil instead
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- Disable built-in zip plugin so it doesn't hijack .xlsx (which is a zip archive);
-- visidata handles them via the BufReadCmd further down.
vim.g.loaded_zipPlugin = 1
vim.g.loaded_zip = 1

-- Work-specific config (DB connections, work commands) lives in
-- the gitignored lua/private/ since this repo is public. Optional.
local private = #vim.api.nvim_get_runtime_file('lua/private/init.lua', false) > 0 and require 'private' or {}
function _G.dbui_portrait() return vim.o.columns < vim.o.lines * 2 end
local dbui_drawer_height = 15 -- portrait only; landscape drawer is a full-height column

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Enable break indent
vim.o.breakindent = true

-- Enable undo/redo changes even after closing and reopening a file
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

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

-- In image buffers, <leader>yi copies the image to the macOS clipboard so it can be
-- pasted into other apps (Messages, Slack, Mail, etc.). Always copies the ORIGINAL
-- file (not the scaled tmp). PNG/JPEG go direct; anything else is converted to PNG.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'image',
  callback = function(args)
    vim.keymap.set('n', '<leader>yi', function()
      local file = vim.api.nvim_buf_get_name(args.buf)
      if file == '' or vim.fn.filereadable(file) == 0 then
        vim.notify('No image file to copy', vim.log.levels.WARN)
        return
      end
      local ext = file:lower():match('%.([^%.]+)$') or ''
      local class = ({ png = '«class PNGf»', jpg = 'JPEG picture', jpeg = 'JPEG picture' })[ext]
      local src = file
      if not class then
        src = vim.fn.stdpath('cache') .. '/snacks-scaled/clipboard.png'
        vim.fn.system({ 'magick', file, src })
        if vim.v.shell_error ~= 0 then
          vim.notify('magick convert failed', vim.log.levels.ERROR)
          return
        end
        class = '«class PNGf»'
      end
      local script = ('set the clipboard to (read (POSIX file "%s") as %s)'):format(
        src:gsub('"', '\\"'), class
      )
      local out = vim.fn.system({ 'osascript', '-e', script })
      if vim.v.shell_error ~= 0 then
        vim.notify('Copy failed: ' .. out, vim.log.levels.ERROR)
      else
        vim.notify('Image copied to clipboard')
      end
    end, { buffer = args.buf, desc = '[Y]ank [I]mage to clipboard' })
  end,
})

-- Visual-select a URL pointing at an image, download it to a cached tmp file, and
-- open it in a new tab -- or, if some tab already has an image window open, vsplit
-- into that tab instead. Relies on snacks.image auto-rendering any buffer whose
-- filetype resolves to 'image' (the same mechanism oil's <C-s> uses) -- no snacks
-- API calls needed here, just get an image file on disk and open it.
local image_exts = { png = true, jpg = true, jpeg = true, gif = true, webp = true, bmp = true, svg = true, avif = true }

local function find_image_win()
  local seen = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(buf)
      local ext = name:match('%.([%a]+)$')
      table.insert(seen, string.format('tab=%s win=%s buf=%s ft=%s name=%s',
        tab, win, buf, vim.bo[buf].filetype, name ~= '' and name or '[No Name]'))
      if ext and image_exts[ext:lower()] then return tab, win end
    end
  end
  vim.notify('[DEBUG] find_image_win: no match\n' .. table.concat(seen, '\n'), vim.log.levels.INFO)
end

local function open_image(file)
  local tab, win = find_image_win()
  if tab then
    vim.api.nvim_set_current_tabpage(tab)
    vim.api.nvim_set_current_win(win)
    vim.cmd('vsplit ' .. vim.fn.fnameescape(file))
  else
    vim.cmd('tabnew ' .. vim.fn.fnameescape(file))
  end
end

local function vsplit_image(file)
  vim.cmd('vsplit ' .. vim.fn.fnameescape(file))
end

-- Shared pipeline for the <leader>li / <leader>ls keymaps: pull a URL out of the
-- visual selection, validate it's an image link, download it to a cached tmp file
-- (or reuse the cache), then hand the local path to `opener`.
local function open_image_link(opener)
  vim.cmd('noau normal! "zy')
  local sel = vim.fn.getreg('z')

  local url = sel:match("https?://[^%s%)%]\"'<>]+")
  if not url then
    vim.notify('No URL found in selection', vim.log.levels.WARN)
    return
  end

  local path = url:match('^([^%?#]+)') or url
  local ext = path:match('%.([%a]+)$')
  if not ext or not image_exts[ext:lower()] then
    vim.notify('Not an image link: ' .. url, vim.log.levels.WARN)
    return
  end

  local cache_dir = vim.fn.stdpath('cache') .. '/link-images'
  vim.fn.mkdir(cache_dir, 'p')
  local tmp = cache_dir .. '/' .. vim.fn.sha256(url):sub(1, 12) .. '.' .. ext:lower()

  if vim.fn.filereadable(tmp) == 1 then
    opener(tmp)
    return
  end

  vim.system({ 'curl', '-fsSL', url, '-o', tmp }, {}, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        vim.notify('Image download failed: ' .. (res.stderr ~= '' and res.stderr or ('exit ' .. res.code)), vim.log.levels.ERROR)
        vim.fn.delete(tmp)
        return
      end
      opener(tmp)
    end)
  end)
end

vim.keymap.set('v', '<leader>li', function()
  open_image_link(open_image)
end, { desc = 'Open selected image link (new tab, or vsplit into an existing image tab)' })

vim.keymap.set('v', '<leader>ls', function()
  open_image_link(vsplit_image)
end, { desc = 'Open selected image link in a vertical split' })

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

-- Long cells (JSON blobs) are cut to this many chars in the results view.
-- psql pads every row to the widest cell in each column, so one big JSON value
-- makes every line tens of KB and rendering/folding them is what crawls. The
-- original lines are kept in dbout_full so <CR> still shows the whole value.
-- Only <CR> knows about this: `ic`/`vic`/<C-]> see the truncated text.
local dbout_max_cell = 60
local dbout_full = {} -- [buf] = { [lnum] = { line = original, layout = ... } }

-- Byte spans {from, to} of each cell, given the display columns of the
-- separators. On ASCII lines display columns are bytes; otherwise walk the
-- separator chars and measure the text between them. nil if the line doesn't
-- fit the layout (footers, blank lines).
local function dbout_cell_spans(line, seps, sepchar)
  local spans, from = {}, 1
  if not line:find '[\128-\255]' then
    if #seps > 0 and #line < seps[#seps] then return nil end
    for _, col in ipairs(seps) do
      spans[#spans + 1] = { from, col - 1 }
      from = col + 1
    end
  else
    local width, pos, k = 0, 1, 1
    while k <= #seps do
      local s = line:find(sepchar, pos, true)
      if not s then return nil end
      width = width + vim.api.nvim_strwidth(line:sub(pos, s))
      pos = s + 1
      if width == seps[k] then
        spans[#spans + 1] = { from, s - 1 }
        from, k = s + 1, k + 1
      elseif width > seps[k] then
        return nil
      end
    end
  end
  spans[#spans + 1] = { from, #line }
  return spans
end

-- Column layout from a header separator: psql `----+----` (cells padded with
-- a space each side, joined by `|`) or sqlcmd `---- ----` (joined by a space).
-- nil when no column needs truncating.
local function dbout_layout(sep)
  local psql = sep:find('+', 1, true) ~= nil
  local layout = { sepchar = psql and '|' or ' ', pad = psql and 1 or 0, seps = {}, new_seps = {}, widths = {} }
  local dashes, col, wide = {}, 0, false
  for s, e in sep:gmatch '()%-+()' do
    local content = (e - s) - 2 * layout.pad
    local w = math.min(content, dbout_max_cell + 1) -- +1 for the …
    wide = wide or w < content
    layout.widths[#layout.widths + 1] = w < content and w or false
    dashes[#dashes + 1] = ('-'):rep(w + 2 * layout.pad)
    layout.seps[#layout.seps + 1] = e
    col = col + w + 2 * layout.pad + 1
    layout.new_seps[#layout.new_seps + 1] = col
  end
  layout.seps[#layout.seps], layout.new_seps[#layout.new_seps] = nil, nil
  layout.sep = table.concat(dashes, psql and '+' or ' ')
  return wide and layout or nil
end

local function dbout_truncate(buf)
  -- FileType can fire again on a buffer that's already been done.
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local done = dbout_full[buf]
  if done and vim.deep_equal(done.shown, lines) then return end
  dbout_full[buf] = nil
  local full, max = {}, dbout_max_cell
  -- By display width, so wide (CJK) chars don't overflow the column.
  local function cut(s)
    if vim.api.nvim_strwidth(s) <= max then return s end
    local n = max
    s = vim.fn.strcharpart(s, 0, n)
    while vim.api.nvim_strwidth(s) > max do
      n = n - math.ceil((vim.api.nvim_strwidth(s) - max) / 2)
      s = vim.fn.strcharpart(s, 0, n)
    end
    return s .. '…'
  end

  if (lines[1] or ''):match '^%-%[ RECORD' then
    for i, line in ipairs(lines) do
      local head, value = line:match '^(.-|%s?)(.*)$'
      if value and vim.api.nvim_strwidth(value) > max then
        full[i] = { line = line }
        lines[i] = head .. cut(value)
      end
    end
  else
    local layout
    for i, line in ipairs(lines) do
      local is_sep = i > 1 and line:match '^%-[%-+ ]*$'
      if line ~= '' and (lines[i + 1] or ''):match '^%-[%-+ ]*$' then
        layout = dbout_layout(lines[i + 1]) -- header row of a new result set
      end
      if layout and is_sep then
        lines[i] = layout.sep
      elseif layout and line ~= '' and not line:match '^%(%d+ rows?' then
        local spans = dbout_cell_spans(line, layout.seps, layout.sepchar)
        if spans then
          local cells, pad = {}, (' '):rep(layout.pad)
          for k, span in ipairs(spans) do
            local cell = line:sub(span[1], span[2])
            local w = layout.widths[k]
            if w then
              cell = cut(vim.trim(cell))
              cell = pad .. cell .. (' '):rep(w - vim.api.nvim_strwidth(cell)) .. pad
            end
            cells[k] = cell
          end
          full[i] = { line = line, layout = layout }
          lines[i] = table.concat(cells, layout.sepchar)
        end
      end
    end
  end

  if next(full) == nil then return end
  dbout_full[buf] = full
  -- Results buffers are 'nomodifiable' once the query finishes.
  local undolevels, modifiable = vim.bo[buf].undolevels, vim.bo[buf].modifiable
  vim.bo[buf].undolevels, vim.bo[buf].modifiable = -1, true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].undolevels, vim.bo[buf].modifiable = undolevels, modifiable
  vim.bo[buf].modified = false
  full.shown = lines
end

-- dadbod-ui results: <CR> opens the cell under the cursor in a vsplit, run
-- through jq when it's JSON. Truncated lines are resolved against their
-- original via dbout_full. Otherwise table layout goes through dbui's `ic`
-- text object; expanded layout (\x, "-[ RECORD 1 ]-") isn't understood by
-- `ic`, so there the value is just everything after the first `|` on the line.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dbout',
  callback = function(args)
    -- Synchronous so the full-width lines never get drawn. Fires again when
    -- the query finishes (`edit!` reloads the file), which is the real pass.
    dbout_truncate(args.buf)

    -- Layout: drawer fixed, query a few lines, results get the rest.
    -- dadbod opens results as a full-width `botright` preview window (which on
    -- landscape also sits under the drawer), and it fires this FileType twice,
    -- on open and again on finish, shuffling heights in between. So move the
    -- results directly below the query and set every height explicitly.
    -- winfixheight keeps drawer and query put when the cell view splits off,
    -- so equalalways only balances results vs cell view.
    vim.schedule(function()
      local win = vim.fn.bufwinid(args.buf)
      if win == -1 then return end
      local query, drawer
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local b = vim.api.nvim_win_get_buf(w)
        if vim.bo[b].filetype == 'dbui' then
          drawer = w
        elseif vim.b[b].dbui_db_key_name and vim.bo[b].filetype ~= 'dbout' then
          query = w
        end
      end
      if not query then return end
      vim.fn.win_splitmove(win, query, { rightbelow = true })
      -- Preview windows come with winfixheight; it has to be off for the
      -- results to absorb the rows the others give up.
      vim.wo[win].winfixheight = false
      if drawer and _G.dbui_portrait() then vim.api.nvim_win_set_height(drawer, dbui_drawer_height) end
      vim.api.nvim_win_set_height(query, 6)
      vim.wo[query].winfixheight = true
    end)

    vim.keymap.set('n', '<CR>', function()
      local value
      local entry = (dbout_full[args.buf] or {})[vim.fn.line '.']
      if entry and entry.layout then
        local col, k = vim.fn.col '.', nil
        local shown = dbout_cell_spans(vim.api.nvim_get_current_line(), entry.layout.new_seps, entry.layout.sepchar)
        for i, span in ipairs(shown or {}) do
          if col <= span[2] + 1 then
            k = i
            break
          end
        end
        local orig = dbout_cell_spans(entry.line, entry.layout.seps, entry.layout.sepchar)
        local span = orig and orig[k or #orig]
        value = span and entry.line:sub(span[1], span[2])
      elseif entry then
        value = entry.line:match '^.-|%s?(.*)$'
      elseif vim.fn.getline(1):match '^%-%[ RECORD' then
        value = vim.api.nvim_get_current_line():match '^.-|%s?(.*)$'
      else
        local saved = vim.fn.getreg '"'
        vim.cmd 'normal yic'
        value = vim.fn.getreg '"'
        vim.fn.setreg('"', saved)
      end
      value = vim.trim(value or '')
      if value == '' then return end

      local ft = 'text'
      if value:match '^[%[{]' then
        local pretty = vim.fn.system({ 'jq', '.' }, value)
        if vim.v.shell_error == 0 then
          value, ft = pretty, 'json'
        end
      end

      -- Split the results window itself rather than the whole screen, so the
      -- drawer and query keep their size.
      local results_win = vim.api.nvim_get_current_win()
      vim.cmd(_G.dbui_portrait() and 'rightbelow new' or 'rightbelow vnew')
      local buf = vim.api.nvim_get_current_buf()
      -- Closing the cell view (q or :q) would otherwise hand focus to the
      -- drawer; go back to the results instead. Only when the cell view was
      -- the focused window, so closing it from elsewhere doesn't steal focus.
      local cell_win = vim.api.nvim_get_current_win()
      vim.api.nvim_create_autocmd('WinClosed', {
        pattern = tostring(cell_win),
        once = true,
        callback = function()
          if vim.api.nvim_get_current_win() ~= cell_win then return end
          vim.schedule(function()
            if vim.api.nvim_win_is_valid(results_win) then vim.api.nvim_set_current_win(results_win) end
          end)
        end,
      })
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(value, '\n', { trimempty = true }))
      vim.bo[buf].buftype = 'nofile'
      vim.bo[buf].bufhidden = 'wipe'
      vim.bo[buf].swapfile = false
      vim.bo[buf].filetype = ft
      vim.b[buf].dbui_cell = true -- so :DBUIQuit closes it too
      vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf })
    end, { buffer = args.buf, desc = 'Inspect cell in vsplit' })

    -- Hop between cells on the current line. Lands just past the "| " so the
    -- cursor stays in the same column position even for blank cells.
    vim.keymap.set('n', '<Tab>', function()
      vim.fn.search([[| \zs.]], 'W', vim.fn.line '.')
    end, { buffer = args.buf, desc = 'Next cell' })
    vim.keymap.set('n', '<S-Tab>', function()
      vim.fn.search([[\(^\|| \)\zs.]], 'bW', vim.fn.line '.')
    end, { buffer = args.buf, desc = 'Previous cell' })
  end,
})

-- Force snacks.nvim to re-render images when re-entering buffer (fixes oil.nvim back-and-forth in tmux)
-- When leaving an image buffer, snacks sets placement.hidden=true but never resets it on re-enter.
-- Resolve through the scale wrapper because the cached Image is keyed by the scaled tmp path,
-- not by the original buffer file name.
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) then return end
    if vim.bo[args.buf].filetype ~= 'image' then return end
    vim.schedule(function()
      local file = vim.api.nvim_buf_get_name(args.buf)
      if _G._snacks_image_scale then file = _G._snacks_image_scale(file) end
      local ok, img = pcall(Snacks.image.image.new, file)
      if not ok or not img then return end
      for _, p in pairs(img.placements) do
        p.hidden = false
        p._state = nil
        p:update()
      end
    end)
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added via a link or github org/name. To run setup automatically, use `opts = {}`
  { 'NMAC427/guess-indent.nvim', opts = {} },

  -- Alternatively, use `config = function() ... end` for full control over the configuration.
  -- If you prefer to call `setup` explicitly, use:
  --    {
  --        'lewis6991/gitsigns.nvim',
  --        config = function()
  --            require('gitsigns').setup({
  --                -- Your gitsigns configuration here
  --            })
  --        end,
  --    }
  --
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`.
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      signs = {
        add = { text = '+' }, ---@diagnostic disable-line: missing-fields
        change = { text = '~' }, ---@diagnostic disable-line: missing-fields
        delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
        topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
        changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
      },
    },
  },
  { -- Git diff/merge tabs and file history
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles', 'DiffviewRefresh', 'DiffviewFileHistory' },
    keys = {
      { '<leader>dh', '<cmd>DiffviewFileHistory<cr>', desc = 'Diff: repo [H]istory' },
      { '<leader>df', '<cmd>DiffviewFileHistory %<cr>', desc = 'Diff: current [F]ile history' },
      { '<leader>do', '<cmd>DiffviewOpen<cr>', desc = 'Diff: [O]pen (working tree vs HEAD)' },
      { '<leader>dc', '<cmd>DiffviewClose<cr>', desc = 'Diff: [C]lose' },
    },
  },
  { -- GitHub PRs, reviews, and checks (uses the gh CLI for auth)
    'pwntester/octo.nvim',
    cmd = 'Octo',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim', 'nvim-tree/nvim-web-devicons' },
    opts = { picker = 'telescope' },
    keys = {
      { '<leader>gp', '<cmd>Octo pr list<cr>', desc = 'GitHub: [P]R list' },
      { '<leader>gc', '<cmd>Octo pr checks<cr>', desc = 'GitHub: PR [C]hecks' },
      { '<leader>gd', '<cmd>Octo pr diff<cr>', desc = 'GitHub: PR [D]iff' },
      { '<leader>gr', '<cmd>Octo review start<cr>', desc = 'GitHub: start [R]eview' },
      { '<leader>gR', '<cmd>Octo review resume<cr>', desc = 'GitHub: [R]esume review' },
      { '<leader>gs', '<cmd>Octo review submit<cr>', desc = 'GitHub: [S]ubmit review' },
    },
  },
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
  { -- Images in nvim
    'folke/snacks.nvim',
    opts = {
      -- Stock list minus pdf: pdfreader.nvim owns *.pdf, and snacks' own
      -- BufReadCmd would otherwise render page 1 on top of it.
      image = {
        formats = { 'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'tiff', 'heic', 'avif', 'mp4', 'mov', 'avi', 'mkv', 'webm', 'icns' },
      },
      bigfile = { size = 5 * 1024 * 1024 },
    },
    config = function(_, opts)
      require('snacks').setup(opts)

      -- Large PNGs are sent verbatim by snacks (its magick scaling step is skipped
      -- when the source is already PNG), so ghostty/kitty/tmux silently drop them.
      -- Pre-scale PNGs that exceed MAX_W x MAX_H to a tmp file, keyed by src+mtime
      -- so `:e` after a file change picks up a new path. The `WxH>` form preserves
      -- aspect ratio and only shrinks when at least one dim exceeds the limit.
      local MAX_W, MAX_H = 1920, 1920
      local cache_dir = vim.fn.stdpath('cache') .. '/snacks-scaled'
      vim.fn.mkdir(cache_dir, 'p')

      local function maybe_scale(src)
        if not src:lower():match('%.png$') then return src end
        local stat = vim.uv.fs_stat(src)
        if not stat then return src end
        -- Snacks.image.util.dim asserts the PNG signature; nil/false means the file
        -- isn't actually a PNG despite the extension (common with mis-named JPEGs).
        -- In that case snacks would ship the bytes to the terminal tagged as PNG
        -- and rendering silently fails — so re-encode through magick.
        local ok, dim = pcall(Snacks.image.util.dim, src)
        local mismatch = not ok or not dim
        if not mismatch and dim.width <= MAX_W and dim.height <= MAX_H then
          return src
        end
        local key = vim.fn.sha256(src):sub(1, 12) .. '-' .. stat.mtime.sec
        local tmp = cache_dir .. '/' .. key .. '.png'
        if vim.fn.filereadable(tmp) == 0 then
          vim.fn.system({ 'magick', src, '-resize', MAX_W .. 'x' .. MAX_H .. '>', tmp })
        end
        return vim.fn.filereadable(tmp) == 1 and tmp or src
      end

      local buf_mod = require('snacks.image.buf')
      local orig_attach = buf_mod._attach
      buf_mod._attach = function(b, o)
        o = o or {}
        local src = o.src or vim.api.nvim_buf_get_name(b)
        o.src = maybe_scale(src)
        return orig_attach(b, o)
      end

      -- snacks caches the Image object by file path and `sent=true` skips re-transmit,
      -- so `:e` on a replaced file shows the stale encoding. Detect mtime change and
      -- force a re-send (which also calls update() on every placement of that image).
      local img_mod = require('snacks.image.image')
      local orig_new = img_mod.new
      img_mod.new = function(src)
        local img = orig_new(src)
        if not img then return img end
        local stat = vim.uv.fs_stat(img.file)
        if stat then
          local m = stat.mtime.sec
          if img.sent and img._last_mtime and img._last_mtime ~= m then
            img.sent = false
          end
          img._last_mtime = m
        end
        return img
      end

      -- When all placements are removed (e.g. you `-` out to oil and the image buffer
      -- is wiped), snacks tells the terminal to drop the image data — but leaves
      -- img.sent=true on the cached Image. On reopen, place() then skips re-transmit
      -- and the terminal renders nothing (placement stuck on the "identify loading…"
      -- spinner). Reset sent when the image is dropped so the next place() re-sends.
      local orig_del = img_mod.del
      img_mod.del = function(self, pid)
        orig_del(self, pid)
        if not next(self.placements) then
          self.sent = false
        end
      end

      -- Expose for the BufEnter hack below so it operates on the actual scaled path.
      _G._snacks_image_scale = maybe_scale
    end,
  },
  { -- Database
    'tpope/vim-dadbod',
  },
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = { 'tpope/vim-dadbod' },
    config = function()
      if private.dbui_config then private.dbui_config() end

      -- On a portrait screen (or a narrow tmux pane) a 40-col drawer column
      -- eats half the width, so open it as a full-width strip on top instead.
      -- Checked per call, so it follows nvim between monitors. Cells are ~2:1,
      -- hence the `* 2`. Explicit mods (`:vertical DBUI`) still win.
      vim.api.nvim_create_user_command('DBUI', function(opts)
        local mods = opts.mods
        if mods == '' and _G.dbui_portrait() then mods = 'topleft ' .. dbui_drawer_height end
        vim.fn['db_ui#open'](mods)
      end, { force = true })

      -- :DBUIClose only closes the drawer. This closes every DBUI window in
      -- the tab: drawer, query buffers, results and cell views. Query buffers
      -- just go hidden, so unsaved edits survive. If DBUI was all that was
      -- open, the last window is left on an empty buffer instead of quitting.
      vim.api.nvim_create_user_command('DBUIQuit', function()
        local wins, keep = {}, {}
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local b = vim.api.nvim_win_get_buf(w)
          local ft = vim.bo[b].filetype
          if ft == 'dbui' or ft == 'dbout' or vim.b[b].dbui_db_key_name or vim.b[b].dbui_cell then
            wins[#wins + 1] = w
          elseif vim.api.nvim_win_get_config(w).relative == '' then
            keep[#keep + 1] = w
          end
        end
        if #keep == 0 and #wins > 0 then
          local last = table.remove(wins)
          vim.api.nvim_win_call(last, function() vim.cmd 'enew' end)
        end
        for _, w in ipairs(wins) do
          pcall(vim.api.nvim_win_close, w, false)
        end
      end, {})
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'dbui',
        callback = function()
          if _G.dbui_portrait() then vim.wo.winfixheight = true end
        end,
      })
    end,
  },
  { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' } },
  { -- File explorer
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      columns = {
        'icon',
        'size',
        'mtime',
      },
      keymaps = { -- <SPACE> + y to copy file path to clipboard
        ['<leader>t'] = { 'actions.select', opts = { tab = true }, desc = 'Open in new tab' },
        ['<C-s>'] = {
          callback = function()
            local oil_win = vim.api.nvim_get_current_win()
            require('oil.actions').select.callback { vertical = true }
            vim.defer_fn(function()
              if vim.api.nvim_win_is_valid(oil_win) then vim.api.nvim_win_set_width(oil_win, math.floor(vim.o.columns * 0.2)) end
            end, 50)
          end,
          desc = 'Open in split (oil 20%, file 80%)',
        },
        ['<leader>o'] = {
          callback = function()
            local entry = require('oil').get_cursor_entry()
            local dir = require('oil').get_current_dir()
            if entry and dir then vim.fn.system('open ' .. vim.fn.shellescape(dir .. entry.name)) end
          end,
          desc = 'Open in native program',
        },
        ['<leader>y'] = {
          callback = function()
            local entry = require('oil').get_cursor_entry()
            local dir = require('oil').get_current_dir()
            if entry and dir then
              local path = dir .. entry.name
              vim.fn.setreg('+', path)
              vim.notify('Copied: ' .. path)
            end
          end,
          desc = 'Copy file path to clipboard',
        },
      },
      view_options = {
        show_hidden = true,
      },
    },
    config = function(_, opts)
      require('oil').setup(opts)
      vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory' })
    end,
    lazy = false,
  },
  { -- Cursor animations
    'sphamba/smear-cursor.nvim',
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.6,
      stiffness_insert_mode = 0.7,
      trailing_stiffness_insert_mode = 0.7,
      damping = 0.95,
      damping_insert_mode = 0.95,
      distance_stop_animating = 0.5,
    },
  },
  { -- Render markdown (headings, callouts, tables, code blocks) in the buffer
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    -- The default border ('hide') conceal_lines the ``` fences, and snacks.image
    -- hangs mermaid diagrams as virt_lines off the closing fence -- hiding the
    -- line hides the diagram too. 'thin' draws over the fences instead.
    opts = { code = { border = 'thin' } },
    keys = {
      { '<leader>tm', '<cmd>RenderMarkdown toggle<cr>', ft = 'markdown', desc = '[T]oggle [M]arkdown render' },
    },
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
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
  -- Then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(MODULE).setup(opts)`.

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter',
    ---@module 'which-key'
    ---@type wk.Opts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
        { '<leader>d', group = '[D]iff (diffview)' },
        { '<leader>g', group = '[G]itHub (octo)' },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
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
    -- By default, Telescope is included and acts as your picker for everything.

    -- If you would like to switch to a different picker (like snacks, or fzf-lua)
    -- you can disable the Telescope plugin by setting enabled to false and enable
    -- your replacement picker by requiring it explicitly (e.g. 'custom.plugins.snacks')

    -- Note: If you customize your config for yourself,
    -- it’s best to remove the Telescope plugin config entirely
    -- instead of just disabling it here, to keep your config clean.
    enabled = true,
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function() return vim.fn.executable 'make' == 1 end,
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
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- This runs on LSP attach per buffer (see main LSP attach function in 'neovim/nvim-lspconfig' config for more info,
      -- it is better explained there). This allows easily switching between pickers if you prefer using something else!
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf

          -- Find references for the word under your cursor.
          vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

          -- Jump to the implementation of the word under your cursor.
          -- Useful when your language has ways of declaring types without an actual implementation.
          vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

          -- Jump to the definition of the word under your cursor.
          -- This is where a variable was first declared, or where a function is defined, etc.
          -- To jump back, press <C-t>.
          vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

          -- Fuzzy find all the symbols in your current document.
          -- Symbols are things like variables, functions, types, etc.
          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

          -- Fuzzy find all the symbols in your current workspace.
          -- Similar to document symbols, except searches over your entire project.
          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

          -- Jump to the type of the word under your cursor.
          -- Useful when you're not sure what type a variable is and you want to see
          -- the definition of its *type*, not where it was *defined*.
          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        end,
      })

      -- Override default behavior and theme when searching
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        { desc = '[S]earch [/] in Open Files' }
      )

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      {
        'mason-org/mason.nvim',
        ---@module 'mason.settings'
        ---@type MasonSettings
        ---@diagnostic disable-next-line: missing-fields
        opts = {},
      },
      -- Maps LSP server names between nvim-lspconfig and Mason package names.
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --  See `:help lsp-config` for information about keys and how to configure
      ---@type table<string, vim.lsp.Config>
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},

        marksman = {}, -- Markdown: jump to #heading links, heading completion

        stylua = {}, -- Used to format Lua code

        -- Special Lua Config, as recommended by neovim help docs
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = {
                version = 'LuaJIT',
                path = { 'lua/?.lua', 'lua/?/init.lua' },
              },
              workspace = {
                checkThirdParty = false,
                -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                  '${3rd}/luv/library',
                  '${3rd}/busted/library',
                }),
              },
            })
          end,
          settings = {
            Lua = {},
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        -- You can add other tools here that you want Mason to install
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
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
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'default',

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets' },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ---@module 'todo-comments'
    ---@type TodoOptions
    ---@diagnostic disable-next-line: missing-fields
    opts = { signs = false },
  },

  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end

      -- ... and there is more!
      --  Check out: https://github.com/nvim-mini/mini.nvim
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
    config = function()
      -- ensure basic parser are installed
      local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
      require('nvim-treesitter').install(parsers)

      ---@param buf integer
      ---@param language string
      local function treesitter_try_attach(buf, language)
        -- check if parser exists and load it
        if not vim.treesitter.language.add(language) then return end
        -- enables syntax highlighting and other treesitter features
        vim.treesitter.start(buf, language)

        -- enables treesitter based folds
        -- for more info on folds see `:help folds`
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- vim.wo.foldmethod = 'expr'

        -- enables treesitter based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      local available_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end

          local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

          if vim.tbl_contains(installed_parsers, language) then
            -- enable the parser if it is installed
            treesitter_try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
            require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
          else
            -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
            treesitter_try_attach(buf, language)
          end
        end,
      })
    end,
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommended keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, { ---@diagnostic disable-line: missing-fields
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
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
