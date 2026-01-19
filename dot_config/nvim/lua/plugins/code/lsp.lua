-- [[ LSP & COMPLETION ]]
return {
	-- ==========================================
	-- 1. Mason (Tool Manager)
	-- ==========================================
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ui = { border = "rounded" },
		},
	},

	-- ==========================================
	-- 2. Mason-LSPConfig (Bridge Mason <-> LSP)
	-- ==========================================
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		event = { "BufReadPre", "BufNewFile" },
		-- Define configuration options. Lazy.nvim will call setup() automatically.
		opts = function()
			local Servers = require("utils.tables.servers")

			-- Pre-load capabilities and on_attach so they are available in the handler
			-- Use pcall to avoid crashing if cmp is not ready yet
			local capabilities
			local status_ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if status_ok_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities()
			else
				capabilities = vim.lsp.protocol.make_client_capabilities()
			end

			local Shared = require("plugins.code.lsp_config.lsp_shared")

			return {
				ensure_installed = Servers.lsp_ensure_installed,
				automatic_installation = true,
				handlers = {
					-- Default handler for all servers
					function(server_name)
						local server_opts = {
							on_attach = Shared.on_attach,
							capabilities = capabilities,
						}

						-- Check if custom config exists (e.g., lua_ls.lua)
						local ok, custom_config = pcall(require, "plugins.code.lsp_config.servers." .. server_name)
						if ok then
							server_opts = vim.tbl_deep_extend("force", server_opts, custom_config)
						end

						require("lspconfig")[server_name].setup(server_opts)
					end,
				},
			}
		end,
	},

	-- ==========================================
	-- 3. nvim-cmp (Auto-completion)
	-- ==========================================
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			{ "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
					{ name = "path" },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
					}),
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
			})
		end,
	},

	-- ==========================================
	-- 4. Conform.nvim (Formatting)
	-- ==========================================
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		dependencies = { "williamboman/mason.nvim" },
		opts = function()
			local Servers = require("utils.tables.servers")
			return {
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					javascript = { "prettier" },
					typescript = { "prettier" },
				},
				default_format_opts = {
					timeout_ms = 3000,
					async = false,
					lsp_fallback = true,
				},
			}
		end,
		init = function()
			local Servers = require("utils.tables.servers")

			-- Ensure essential formatters are installed via Mason
			vim.api.nvim_create_autocmd("User", {
				pattern = "MasonToolsUpdateCompleted",
				callback = function()
					local mr = require("mason-registry")
					for _, tool in ipairs(Servers.formatters_linters_installed) do
						local p = mr.get_package(tool)
						if not p:is_installed() then
							p:install()
						end
					end
				end,
			})

			vim.keymap.set({ "n", "v" }, "<leader>mp", function()
				require("conform").format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "Format file or range" })
		end,
	},
}
