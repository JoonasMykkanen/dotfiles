return {
  -- main lsp configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    -- automatically install lsps and related tools to stdpath for neovim
    { 'williamboman/mason.nvim', config = true }, -- note: must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'whoissethdaniel/mason-tool-installer.nvim',

    -- useful status updates for lsp.
    -- note: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },

    -- allows extra capabilities provided by nvim-cmp
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    -- brief aside: **what is lsp?**
    --
    -- lsp stands for language server protocol. it's a protocol that helps editors
    -- and language tooling communicate in a standardized fashion.
    --
    -- in general, you have a "server" which is some tool built to understand a particular
    -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). these language servers
    -- are standalone processes that communicate with some "client" - in this case, neovim!
    --
    -- lsp provides neovim with features like:
    --  - go to definition
    --  - find references
    --  - autocompletion
    --  - symbol search
    --  - and more!
    --
    -- thus, language servers are external tools that must be installed separately from
    -- neovim. this is where `mason` and related plugins come into play.
    --
    -- if you're wondering about lsp vs treesitter, you can check out the wonderfully
    -- and elegantly composed help section, `:help lsp-vs-treesitter`

    --  this function gets run when an lsp attaches to a particular buffer.
    --    that is to say, every time a new file is opened that is associated with
    --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    --    function will be executed to configure the current buffer
    vim.api.nvim_create_autocmd('lspattach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- note: remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself.
        --
        -- in this case, we create a function that lets us more easily define mappings specific
        -- for lsp related items. it sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'lsp: ' .. desc })
        end

        -- jump to the definition of the word under your cursor.
        map('gd', require('telescope.builtin').lsp_definitions, '[g]oto [d]efinition')

        -- find references for the word under your cursor.
        map('gr', require('telescope.builtin').lsp_references, '[g]oto [r]eferences')

        -- jump to the implementation of the word under your cursor.
        map('gi', require('telescope.builtin').lsp_implementations, '[g]oto [i]mplementation')

        -- jump to the type of the word under your cursor.
        map('<leader>d', require('telescope.builtin').lsp_type_definitions, 'type [d]efinition')

        -- fuzzy find all the symbols in your current document.
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[d]ocument [s]ymbols')

        -- fuzzy find all the symbols in your current workspace.
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[w]orkspace [s]ymbols')

        -- rename the variable under your cursor.
        map('<leader>rn', vim.lsp.buf.rename, '[r]e[n]ame')

        -- execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your lsp for this to activate.
        map('<leader>ca', vim.lsp.buf.code_action, '[c]ode [a]ction', { 'n', 'x' })

        -- warn: this is not goto definition, this is goto declaration.
        -- map('gd', vim.lsp.buf.declaration, '[g]oto [d]eclaration')

        -- highlight references while your cursor rests on them
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
          client
          and client.supports_method
          and client:supports_method 'textDocument/documentHighlight' -- older + safer check
        then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'cursorhold', 'cursorholdi' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'cursormoved', 'cursormovedi' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('lspdetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end
      end,
    })

    -- lsp servers and clients are able to communicate to each other what features they support.
    -- by default, neovim doesn't support everything that is in the lsp specification.
    -- when you add nvim-cmp, luasnip, etc. neovim now has *more* capabilities.
    -- so, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- enable the following language servers
    --  feel free to add/remove any lsps that you want here. they will automatically be installed.
    --
    --  add any additional override configuration in the following tables. available keys are:
    --  - cmd (table): override the default command used to start the server
    --  - filetypes (table): override the default list of associated filetypes for the server
    --  - capabilities (table): override fields in capabilities. can be used to disable certain lsp features.
    --  - settings (table): override the default settings passed when initializing the server.
    --        for example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

    require('lspconfig').dartls.setup {
      cmd = { 'dart', 'language-server', '--protocol=lsp' },
      filetypes = { 'dart' },
      init_options = {
        closingLabels = true,
        flutterOutline = true,
        onlyAnalyzeProjectsWithOpenFiles = true,
        outline = true,
        suggestFromUnimportedLibraries = true,
      },
      -- root_dir = root_pattern("pubspec.yaml"),
      settings = {
        dart = {
          completeFunctionCalls = true,
          showTodos = true,
        },
      },
      on_attach = function(client, bufnr)
        local keymap = vim.keymap.set
        local opts = { buffer = bufnr, silent = true }
        -- Example: Go to type definition
        -- keymap('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        -- Add more key mappings as needed
      end,
      capabilities = capabilities, -- Important: Pass the capabilities
    }

    local servers = {
      -- clangd = {},
      gopls = {},
      pyright = {},
      -- rust_analyzer = {},
      vtsls = {
        enabled = true,
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
          javascript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      },
      -- ruff = {},
      -- pylsp = {
      --   settings = {
      --     pylsp = {
      --       plugins = {
      --         pyflakes = { enabled = false },
      --         pycodestyle = { enabled = false },
      --         autopep8 = { enabled = false },
      --         yapf = { enabled = false },
      --         mccabe = { enabled = false },
      --         pylsp_mypy = { enabled = false },
      --         pylsp_black = { enabled = false },
      --         pylsp_isort = { enabled = false },
      --       },
      --     },
      --   },
      -- },
      html = { filetypes = { 'html', 'twig', 'hbs' } },
      cssls = {},
      tailwindcss = {},
      dockerls = {},
      sqlls = {},
      terraformls = {},
      jsonls = {},
      yamlls = {},

      lua_ls = {
        settings = {
          lua = {
            completion = {
              callsnippet = 'replace',
            },
            runtime = { version = 'luajit' },
            workspace = {
              checkthirdparty = false,
              library = {
                '${3rd}/luv/library',
                unpack(vim.api.nvim_get_runtime_file('', true)),
              },
            },
            diagnostics = { disable = { 'missing-fields' } },
            format = {
              enable = false,
            },
          },
        },
      },
    }

    -- ensure the servers and tools above are installed
    -- you can check the status or install new tools via `:Mason`
    require('mason').setup()

    -- you can add other tools here that you want mason to install
    -- for you, so that they are available from within neovim.
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua', -- used to format lua code
    })

    require('mason-tool-installer').setup {
      ensure_installed = ensure_installed,
    }

    -- set up each language server
    for server_name, config in pairs(servers) do
      require('lspconfig')[server_name].setup(vim.tbl_deep_extend('force', {
        capabilities = capabilities,
      }, config))
    end
  end,
}
