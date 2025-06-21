return {
  -- First, ensure nvim-treesitter is configured (you already have this)
  {
    'nvim-treesitter/nvim-treesitter',
    -- ... your existing nvim-treesitter config ...
    -- build = ':TSUpdate',
    -- config = function() require('nvim-treesitter.configs').setup({ ... }) end,
  },

  -- Add nvim-ts-context-commentstring
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    -- No specific opts needed for basic Comment.nvim integration,
    -- but it should be loaded before Comment.nvim or at least be available
    -- when Comment.nvim's config function runs.
    -- lazy.nvim handles this if Comment.nvim `dependencies` on it or if loaded earlier.
    -- For simplicity, just ensure it's in your plugin list.
    -- You can make it a dependency of Comment.nvim if you prefer:
    -- dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
  },

  -- Configure Comment.nvim to use the hook
  {
    'numToStr/Comment.nvim',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      -- IMPORTANT: Before setting up Comment.nvim, ensure nvim-ts-context-commentstring
      -- has configured itself or provides the necessary global variable.
      -- Often, just requiring it is enough if it sets a global `vim.g.skip_ts_context_commentstring_module`.
      -- For the pre_hook, it simply needs to be available to be required.

      require('Comment').setup {
        -- Other Comment.nvim options if you have them...
        -- padding = true,
        -- sticky = true,
        --toggler = { line = 'gcc', block = 'gbc' },
        --opleader = { line = 'gc', block = 'gb' },
        --mappings = { basic = true, extra = true },

        -- This is the crucial part for JSX/TSX support:
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end,
  },

  -- Your nvim-treesitter/playground plugin (if you're keeping it)
  -- {
  --   'nvim-treesitter/playground',
  --   cmd = 'TSPlaygroundToggle',
  --   dependencies = { 'nvim-treesitter' },
  -- },
}

