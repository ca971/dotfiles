-- [[ SNACKS NVIM ]]
-- All-in-one plugin for Dashboard, Terminal, Notifier, and Utilities
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,

	-- [[ GLOBAL KEYBINDINGS ]]
	-- Define keys explicitly for which-key integration and cleaner opts
	keys = {
		{
			"<leader>gg",
			function()
				-- Check for unsaved buffers using idiomatic Lua
				local unsaved_buffers = vim.tbl_filter(function(buf)
					return vim.api.nvim_get_option_value("modified", { buf = buf })
				end, vim.api.nvim_list_bufs())

				-- Build a prompt string if there are unsaved files
				local msg = ""
				if #unsaved_buffers > 0 then
					local list = {}
					for _, buf in ipairs(unsaved_buffers) do
						table.insert(list, string.format("%3d: %s", buf, vim.api.nvim_buf_get_name(buf)))
					end
					msg = "Unsaved buffers:\n\n" .. table.concat(list, "\n") .. "\n\nOpen LazyGit anyway?"
				end

				-- Open LazyGit if no unsaved buffers or if user confirms
				if #unsaved_buffers == 0 or vim.fn.confirm(msg, "&Yes\n&No", 2) == 1 then
					require("snacks").lazygit.open()
				end
			end,
			desc = "LazyGit",
		},
		{
			"<leader>uz",
			function()
				require("snacks").zen()
			end,
			desc = "Toggle Zen mode",
		},
		{
			"<leader>sn",
			function()
				require("snacks").notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>D",
			function()
				require("snacks").dashboard.open()
			end,
			desc = "Dashboard",
		},
		{
			"<c-t>",
			function()
				require("snacks").terminal.toggle()
			end,
			desc = "Toggle Terminal",
			mode = { "n", "t" },
		},
	},

	opts = {
		styles = {
			-- Custom layout for notification history
			notification_history = {
				relative = "editor",
				width = 0.9,
				height = 0.9,
			},
		},
		-- [[ NOTIFIER ]]
		notifier = { enabled = true, timeout = 2000 },
		-- [[ STATUSCOLUMN ]]
		statuscolumn = { enabled = true },
		-- [[ TOOLS ]]
		rename = { enabled = false },
		bufdelete = { enabled = false },
		-- [[ INDENT GUIDES ]]
		indent = {
			enabled = true,
			priority = 1,
			animate = {
				enabled = true,
				style = "out",
				easing = "linear",
				duration = { step = 20, total = 500 },
			},
		},
		-- [[ TERMINAL ]]
		terminal = {
			enabled = true,
			win = { position = "float", border = "single" },
		},
		-- [[ WORD NAVIGATION ]]
		words = {
			enabled = true,
			debounce = 200,
			notify_jump = false,
			notify_end = true,
			foldopen = true,
			jumplist = true,
			modes = { "n" },
		},
		-- [[ ZEN MODE ]]
		zen = {
			enabled = true,
			toggles = {
				dim = false,
				git_signs = false,
				mini_diff_signs = false,
				diagnostics = true,
			},
		},
		-- [[ SESSION MANAGEMENT ]]
		session = {
			enabled = true,
			opts = {
				storage = "session", -- default: ~/.local/state/nvim/sessions
				autowrite = true, -- Automatically save session when closing Nvim (VimLeavePre)
				autoread = false, -- Don't restore at startup to keep dashboard visible
			},
		},
		quickfile = { enabled = true },
		-- [[ LAZYGIT CONFIG ]]
		lazygit = {
			enabled = true,
			configure = true,
			config = {
				os = { editPreset = "nvim-remote" },
				gui = { nerdFontsVersion = "3" },
				git = { overrideGpg = true },
			},
		},
		-- [[ DASHBOARD ]]
		dashboard = {
			opts = {
				reset = false,
			},
			sections = function()
				-- Path to ASCII art file (Ensure this file exists in your config)
				local header_path = vim.fn.stdpath("config") .. "/static/header.cat"

				-- --- DYNAMIC GREETING LOGIC ---
				-- Calculate greeting based on time of day
				local hour = tonumber(vim.fn.strftime("%H"))
				local part_id = math.floor((hour + 6) / 8) + 1
				local day_part = ({ "Good evening", "Good morning", "Good afternoon", "Good evening" })[part_id]
				local user = os.getenv("USER") or os.getenv("USERNAME") or "user"
				local greeting_msg = string.format("%s, %s!", day_part, user)
				-- --------------------------------

				return {
					-- 1. ASCII HEADER
					{
						section = "terminal",
						cmd = "cat " .. header_path,
						height = 9,
						width = 72,
						padding = 1,
					},

					-- 2. DYNAMIC GREETING
					-- Using robust 'text' block for centering
					{
						padding = 1,
						align = "center",
						text = { greeting_msg, hl = "header" },
					},

					-- 3. QUICK ACTIONS (Button Group)
					{
						title = "Builtin Actions",
						indent = 2,
						padding = 1,
						{
							icon = " ",
							key = "f",
							desc = "Find File",
							action = ":lua Snacks.dashboard.pick('files')",
						},
						{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
						{
							icon = " ",
							key = "r",
							desc = "Recent Files",
							action = ":lua Snacks.dashboard.pick('oldfiles')",
						},
						{
							icon = " ",
							key = "g",
							desc = "Find Text",
							action = ":lua Snacks.dashboard.pick('live_grep')",
						},
						{ icon = " ", key = "s", desc = "Restore Session", action = ":lua Snacks.session.pick()" },
						{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
					},

					-- 4. RECENT PROJECTS
					{
						title = "Recent Projects",
						section = "projects",
						indent = 2,
						padding = 1,
					},

					-- 5. SYSTEM & CONFIG (Button Group)
					{
						title = "System & Config",
						indent = 2,
						padding = 1,
						{
							icon = " ",
							key = "c",
							desc = "Config",
							action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
						},
						{
							icon = " ",
							key = "F",
							desc = "Diagnostic Info",
							hl = "DiagnosticInfo",
							action = ":lua Snacks.dashboard.pick('files')",
						},
						{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
						{ icon = " ", key = "u", desc = "Update Plugins", action = ":Lazy update" },
						{ icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
						{ icon = "󱁤 ", key = "m", desc = "Mason", action = ":Mason" },
					},

					-- 6. FOOTER
					{ section = "startup", padding = 1 },
				}
			end,
		},
	},
}
