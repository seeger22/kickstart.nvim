return {
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
}
