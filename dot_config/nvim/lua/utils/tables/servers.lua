-- [[ SERVER CONFIGURATION ]]
-- Definitions for Treesitter parsers, LSP servers, Formatters, and Linters.
-- Organized by installation priority: 'ensure_installed' (immediate) vs list (lazy).
return {
  -- [[ TREEITTER PARSERS ]]
  -- Core parsers that are always installed for syntax highlighting
  -- Full list: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
  ---@type string[]
  treesitter_ensure_installed = {
    "bash",
    "c",
    "cpp",
    "css",
    "diff",
    "dockerfile",
    "go",
    "gomod",
    "html",
    "javascript",
    "json",
    "jq",
    "jsdoc",
    "latex",
    "lua",
    "luadoc",
    "make",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "regex",
    "rust",
    "sql",
    "ssh_config",
    "svelte",
    "toml",
    "typescript",
    "vim",
    "vimdoc",
    "vue",
    "xml",
    "yaml",
    "zig",
  },

  -- [[ LANGUAGE SERVER PROTOCOL (LSP) ]]
  -- Essential servers installed immediately upon startup
  -- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/configs
  ---@type string[]
  lsp_ensure_installed = {
    "bashls",
    "clangd",
    "cssls",
    "denols",
    "dockerls",
    "html",
    "jsonls",
    "jqls",
    "lua_ls",
    "pylsp",
    "sqlls",
    "svelte",
    "tailwindcss",
    "ts_ls",
    "yamlls",
    "vimls",
  },
  -- Full list of LSP servers available for lazy installation
  -- Installed automatically if a corresponding file type is opened
  -- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/configs
  ---@type string[]
  lsp_servers = {
    "cssmodules_ls",
    "docker_compose_language_service",
    "emmet_ls",
    "graphql",
    "intelephense",
    "julials",
    "ltex",
    "marksman",
    "prismals",
    "pyright",
    "rust_analyzer",
    "taplo",
    "templ", -- Requires gopls in PATH, Mason might fail depending on OS
    "texlab",
    "vtsls",
    "vuels",
    "zls",
    -- "phpactor", -- Disabled: optional alternative to intelephense
  },

  -- [[ FORMATTING & LINTING ]]
  -- Essential formatters and linters installed immediately
  ---@type string[]
  formatters_linters_installed = {
    "prettier",
    "stylua",
    "shellcheck",
    "markdownlint",
  },
  -- Additional tools available for lazy installation
  ---@type string[]
  formatters_linters = {
    "black",
    "eslint_d",
    "gofumpt",
    "goimports",
    "golangci-lint",
    "golines",
    "isort",
    "latexindent",
    "markdownlint",
    "prettier",
    "pylint",
    "shfmt",
    "templ",
    "sql-formatter",
    "shellcheck",
    "stylua",
    "tflint",
    "yamllint",
  },
  -- Tools that should be available in the system PATH (Not managed by Mason)
  ---@type string[]
  external_formatters = {
    "beautysh",
    "flake8",
    "ruff",
  },

  -- Debug Adapter Protocol (DAP) clients to install and configure during bootstrap.
  -- Supported DAPs: https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
  ---@type string[]
  debugger_adapter = {
    "codelldb", -- C-Family
    "delve",    -- Go
    "python",   -- Python (debugpy)
  },
}
