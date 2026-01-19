-- [[ EDITOR PLUGINS ]]
-- Essential tools for editing, navigation, and project management.

-- [[ SEARCH & REPLACE ]]
-- Powerful search and replace across multiple files
return {
	{
		"MagicDuck/grug-far.nvim",
		opts = { headerMaxWidth = 80 },
		cmd = { "GrugFar", "GrugFarWithin" },
		keys = {
			{
				"<leader>sr",
				function()
					local grug = require("grug-far")
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.open({
						transient = true,
						prefills = {
							filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						},
					})
				end,
				mode = { "n", "x" },
				desc = "Search and Replace",
			},
		},
	},

	-- [[ JUMP NAVIGATION ]]
	-- Flash enhances the built-in search functionality by showing labels
	-- at the end of each match, letting you quickly jump to a specific location.
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		vscode = true,
		---@type Flash.Config
		opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "o", "x" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
      -- Simulate nvim-treesitter incremental selection
      {
        "<c-space>",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter({
            actions = {
              ["<c-space>"] = "next",
              ["<BS>"] = "prev"
            }
          })
        end,
        desc = "Treesitter Incremental Selection"
      },
    },
	},

	-- [[ KEYBINDINGS HELP ]]
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern", -- "helix", "modern", "classic"
			icons = {
				breadcrumb = "»", -- Symbol used for the path
				separator = "➜",
				group = "+",
			},
			win = {
				border = "rounded", -- Style of the popup window
			},
			disable = { filetypes = { "TelescopePrompt" } },
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)

			-- Register keybinding groups for Which-Key
			-- This helps visualize the organization when typing <leader>
			wk.add({
				{ "<leader><tab>", group = "Tabs" },
				{ "<leader>c", group = "Code" },
				{ "<leader>d", group = "Debug" },
				{ "<leader>f", group = "Find/Telescope" },
				{ "<leader>g", group = "Git" },
				{ "<leader>h", group = "Hunks (Git)" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>u", group = "UI" },
				{ "<leader>q", group = "Quit/Session" },
				{ "<leader>w", group = "Workspace/Session" },
				{ "<leader>e", group = "Explorer" },
				{ "<leader>x", group = "Diagnostic/Quickfix" },
				{ "g", group = "Goto" },
				{ "gs", group = "Surround" },
				{ "z", group = "Fold" },
			})
		end,
	},

	-- [[ FILE EXPLORER ]]
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Explorer" },
		},
		opts = {
			filesystem = {
				use_libuv_file_watcher = true,
				filtered_items = {
					visible = false,
					hide_dotfiles = true,
					hide_gitignored = true,
				},
			},
			window = {
				position = "left",
				width = 40,
				mappings = {
					["<space>"] = "none",

					-- ==========================================
					-- FUZZY SEARCH ACTIVATION
					-- ==========================================
					["s"] = "fuzzy_finder",

					-- Note: To always open in a vertical split, use <C-v> on the file.
				},
			},
		},
	},

	-- [[ FUZZY FINDER ]]
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
		},
		config = function()
			require("telescope").setup()
		end,
	},

	-- [[ GIT SIGNS ]]
	{
		"lewis6996/gitsigns.nvim",
		enabled = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					-- ROBUST FIX:
					-- Convert 'opts' to a table if it is a simple description string
					-- This prevents the error "attempt to index a string value"
					if type(opts) == "string" then
						opts = { desc = opts }
					end

					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Next Hunk" })

				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Prev Hunk" })

				-- Actions
				map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
				map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage Hunk")
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset Hunk")
				map("n", "<leader>hS", gs.stage_buffer, "Stage Buffer")
				map("n", "<leader>hu", gs.undo_stage_hunk, "Undo Stage Hunk")
				map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
			end,
		},
	},

	-- [[ GIT INTERFACE ]]
	-- Lazygit (Ultimate Git TUI)
	{
		"kdheepak/lazygit.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Telescope integration (if you have multiple projects)
			"nvim-telescope/telescope.nvim",
		},
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		keys = {
			-- Standard Power User shortcut for Git
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit (UI)" },
		},
		config = function()
			-- Load Telescope extension for LazyGit (Optional but powerful)
			-- Allows listing all project folders and opening LazyGit in them
			pcall(require("telescope").load_extension, "lazygit")
		end,
	},

	-- [[ DIFF VIEWER ]]
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		keys = {
			{ "<leader>go", "<cmd>DiffviewOpen<cr>", desc = "Open Diff View" },
			{ "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
		},
		opts = {
			enhanced_diff_hl = true, -- Enhanced diff highlighting
			view = {
				default = { layout = "diff2_horizontal" }, -- Default view mode
			},
		},
	},

	-- [[ DOCKER INTERFACE ]]
	{
		"nmartin84/lazydocker.nvim",
		enabled = false,
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "LazyDocker",
		keys = {
			-- Shortcut: <leader>dk (Docker Key)
			{ "<leader>dk", "<cmd>LazyDocker<cr>", desc = "LazyDocker (UI)" },
		},
		opts = {},
		config = function()
			require("lazydocker").setup({
				-- Optional configuration: For a rounded floating window
				-- If you prefer a normal tab, you can remove this
				border = "curved",
			})
		end,
	},

	-- [[ DOTFILES MANAGER ]]
	{
		"xvzc/chezmoi.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("chezmoi").setup({
				-- Your configurations
			})
		end,
	},
}
