return {
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
}
