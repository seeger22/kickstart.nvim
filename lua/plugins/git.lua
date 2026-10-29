return {
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
}
