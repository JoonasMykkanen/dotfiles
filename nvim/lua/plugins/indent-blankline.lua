return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      scope = {
        enabled = true,
        highlight = 'Function',
      },
      indent = {
        smart_indent_cap = true,
        repeat_linebreak = false,
      },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      enable = true,
      max_lines = 1,
      mode = 'cursor',
      separator = nil,
    },
  },
}
