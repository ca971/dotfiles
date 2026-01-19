-- [[ SERVER CONFIGURATION ]]
-- Definitions for Treesitter parsers, LSP servers, Formatters, and Linters.
-- Organized by installation priority: 'ensure_installed' (immediate) vs list (lazy).
return {
	-- [[ TREEITTER PARSERS ]]
	-- Core parsers that are always installed for syntax highlighting
	treesitter_ensure_installed = {
		"bash",
		"c",
		"cpp",
		"diff",
		"http",
		"javascript",
		"json",
		"jsonc",
		"lua",
		"markdown",
		"markdown_inline",
		"printf",
		"python",
		"query",
		"regex",
		"toml",
		"vim",
		"vimdoc",
		"yaml",
	},
	-- Optional parsers loaded on demand (lazy loading)
	treesitter_parsers = {
		"css",
		"csv",
		"dockerfile",
		"gitcommit",
		"gitignore",
		"go",
		"html",
		"javascript",
		"jq",
		"jsdoc",
		"luadoc",
		"luap",
		"php",
		"prisma",
		"python",
		"sql",
		"ssh_config",
		"svelte",
		"toml",
		"typescript",
		"vim",
		"vimdoc",
		"vue",
		"xml",
		"zig",
	},

	-- [[ LANGUAGE SERVER PROTOCOL (LSP) ]]
	-- Essential servers installed immediately upon startup
	lsp_ensure_installed = {
		"cssls",
		"denols",
		"html",
		"lua_ls",
		"pylsp",
		"ts_ls",
		"vimls",
	},
	-- Full list of LSP servers available for lazy installation
	-- Installed automatically if a corresponding file type is opened
	lsp_servers = {
		"bashls",
		"clangd",
		"cssmodules_ls",
		"docker_compose_language_service",
		"dockerls",
		"emmet_ls",
		"graphql",
		"intelephense",
		"jqls",
		"jsonls",
		"julials",
		"ltex",
		"marksman",
		"prismals",
		"pyright",
		"rust_analyzer",
		"sqlls",
		"svelte",
		"tailwindcss",
		"taplo",
		"templ", -- Requires gopls in PATH, Mason might fail depending on OS
		"texlab",
		"vtsls",
		"vuels",
		"yamlls",
		"zls",
		-- "phpactor", -- Disabled: optional alternative to intelephense
	},

	-- [[ FORMATTING & LINTING ]]
	-- Essential formatters and linters installed immediately
	formatters_linters_installed = {
		"prettier",
		"stylua",
		"shellcheck",
		"markdownlint",
	},
	-- Additional tools available for lazy installation
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
	external_formatters = {
		"beautysh",
		"flake8",
		"ruff",
	},
}
