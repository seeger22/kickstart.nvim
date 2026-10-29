-- dadbod + dadbod-ui: portrait-aware drawer layout, truncated result cells
-- with a full-value <CR> view, and :DBUIQuit. Connections and work commands
-- come from the optional lua/private/ module.
local private = require 'config.private'

local function dbui_portrait() return vim.o.columns < vim.o.lines * 2 end
local dbui_drawer_height = 15 -- portrait only; landscape drawer is a full-height column

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
  -- Cleared so re-evaluating this spec (lazy change detection) doesn't stack handlers.
  group = vim.api.nvim_create_augroup('dbout-results', { clear = true }),
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
      if drawer and dbui_portrait() then vim.api.nvim_win_set_height(drawer, dbui_drawer_height) end
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
      vim.cmd(dbui_portrait() and 'rightbelow new' or 'rightbelow vnew')
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

return {
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
        if mods == '' and dbui_portrait() then mods = 'topleft ' .. dbui_drawer_height end
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
          if dbui_portrait() then vim.wo.winfixheight = true end
        end,
      })
    end,
  },
  { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' } },
}
