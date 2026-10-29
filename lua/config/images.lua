-- Image helpers: copy an image buffer to the clipboard, open image URLs, and
-- keep snacks.image renders alive across buffer switches.

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
