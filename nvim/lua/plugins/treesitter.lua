return {
  -- First plugin: nvim-treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    -- main = 'nvim-treesitter.configs', -- Not typically needed if 'nvim-treesitter.configs' is the default or you use config = function()
    event = { 'BufReadPre', 'BufNewFile' }, -- Or other events to load it appropriately
    dependencies = {
      -- You can list dependencies for nvim-treesitter itself here if any
      -- e.g., 'nvim-treesitter/nvim-treesitter-textobjects' if you use it
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'lua',
          'dart',
          'python',
          'javascript',
          'typescript',
          'vimdoc',
          'vim',
          'regex',
          'terraform',
          'sql',
          'dockerfile',
          'toml',
          'json',
          'java',
          'groovy',
          'go',
          'gitignore',
          'graphql',
          'yaml',
          'make',
          'cmake',
          'markdown',
          'markdown_inline',
          'bash',
          'tsx',
          'css',
          'html',
        },
        auto_install = true,
        highlight = {
          enable = true,
          -- additional_vim_regex_highlighting = false, -- This is the default
        },
        indent = { enable = true },
        -- Add other modules here if you use them, e.g.:
        -- incremental_selection = {
        --   enable = true,
        --   keymaps = {
        --     init_selection = '<c-space>',
        --     node_incremental = '<c-space>',
        --     scope_incremental = '<c-s>',
        --     node_decremental = '<bs>',
        --   },
        -- },
      }
    end,
  },

  -- Second plugin: nvim-treesitter-playground
  {
    'nvim-treesitter/playground',
    cmd = 'TSPlaygroundToggle',
    dependencies = { 'nvim-treesitter' }, -- Good practice to ensure treesitter is available
  },

  -- ... any other plugins you might have in this file or setup
}
