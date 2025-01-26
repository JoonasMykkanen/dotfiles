return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  opts = {
    enable = true, -- Enable the context window
    max_lines = 1, -- Show only the first line of the context
    trim_scope = 'inner', -- Show the closest inner scope
    patterns = { -- Specify patterns for context
      default = {
        'class',
        'function',
        'method',
      },
    },
    mode = 'topline', -- Line used to calculate context
    separator = nil, -- No separator line between context and code
  },
}
