return {
  {
    'windwp/nvim-ts-autotag',
    event = 'InsertEnter',
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },
  -- {
  --   'neovim/nvim-lspconfig',
  --   dependencies = { 'aca/emmet-ls' },
  --   config = function()
  --     require('lspconfig').emmet_ls.setup {}
  --   end,
  -- },
}
