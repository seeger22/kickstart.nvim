return {
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
}
