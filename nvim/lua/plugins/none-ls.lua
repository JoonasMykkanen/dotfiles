return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'jayp0521/mason-null-ls.nvim', -- Ensure dependencies are installed
  },
  config = function()
    local null_ls = require 'null-ls'
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics

    -- Setup Mason-Null-LS
    require('mason-null-ls').setup {
      ensure_installed = {
        'prettier',  -- TS/JS formatter
        'stylua',    -- Lua formatter
        'eslint_d',  -- TS/JS linter
        'shfmt',     -- Shell formatter
        'checkmake', -- Makefile linter
        'gofmt',     -- Go formatter
        'black',     -- Python
      },
      automatic_installation = true,
    }

    -- Define Null-LS sources
    local sources = {
      diagnostics.checkmake,
      formatting.prettier.with {
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'css', 'scss', 'json', 'yaml', 'markdown' },
        extra_args = { '--tab-width', '2' },
      },
      formatting.stylua,
      formatting.shfmt.with { args = { '-i', '4' } },
      formatting.terraform_fmt,
      formatting.gofmt,
      formatting.black.with {
        extra_args = { '--line-length', '120' },
      },
    }

    -- Auto-format on save
    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
    null_ls.setup {
      sources = sources,
      on_attach = function(client, bufnr)
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format { async = false }
            end,
          })
        end
      end,
    }
  end,
}
