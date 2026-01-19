-- [[ USER PROFILES ]]
-- Define environments for different users (dev, admin, etc.)
-- Each profile sets active plugins, languages, themes, and AI tool preferences.
return {
	-- [[ ACTIVE USER SELECTION ]]
	-- Select which user profile to load based on global settings
	active_user = Settings.active_user or "noconfig",

	-- [[ DEV USER ]]
	-- Full-featured development environment with coding, AI, and web support
	dev = {
		name = "Dev",
		namespace = Settings.namespace or "bly",
		-- Load specific plugin groups (directories)
		plugins = {
			"code",
			"ai",
			"misc",
		},
		-- Supported languages for this profile
		lang = { "python", "docker", "web" },
		-- Colorscheme preferences
		colorscheme = {
			name = Settings.active_colorscheme or "tokyonight",
			theme = Settings.active_colorscheme_theme or "tokyonight-night",
		},
		-- Override core configurations (options, keymaps, autocmds)
		bypass = {
			options = false, -- Use global options
			keymaps = true, -- Override global keymaps
			autocmds = false, -- Use global autocmds
		},
		-- AI Tools Configuration
		ai_tools = {
			enabled = true,
			-- Directories where AI tools are permitted to run
			public_dirs = {
				"~/.config/nvim",
				"~/projects/public",
				"~/dev",
				"~/dotfiles",
			},
			-- Toggle specific AI assistants
			tools = {
				copilot = {
					enabled = Settings.enable_ai and Settings.enable_copilot,
				},
				tabnine = {
					enabled = Settings.enable_ai and Settings.enable_tabnine,
				},
				chatgpt = {
					enabled = Settings.enable_ai and Settings.enable_chatgpt,
					allowed_commands = { "ExplainCode", "GenerateTests" },
				},
				gen = {
					enabled = Settings.enable_ai and Settings.enable_gen,
				},
				codeium = {
					enabled = Settings.enable_ai and Settings.enable_codeium,
				},
				continue = {
					enabled = Settings.enable_ai and Settings.enable_continue,
				},
				-- Add other AI tools here
			},
		},
	},

	-- [[ ADMIN USER ]]
	-- Lightweight administration environment
	admin = {
		name = "Admin",
		namespace = Settings.namespace or "free",
		plugins = {
			"misc",
		},
		lang = {
			"bash",
			"zsh",
			"python",
		},
		colorscheme = {
			name = Settings.active_colorscheme or "catppuccin",
			theme = Settings.active_colorscheme_theme or "catppuccin-macchiato",
		},
		bypass = {
			options = true, -- Override global options
			keymaps = false, -- Use global keymaps
			autocmds = true, -- Override global autocmds
		},
		ai_tools = {
			enabled = false, -- All AI tools deactivated for this user
		},
	},

	-- [[ NO CONFIG USER ]]
	-- Fallback minimal configuration
	noconfig = {
		name = "Noconfig",
		namespace = Settings.namespace or "",
		plugins = {},
		lang = {},
		colorscheme = {
			name = Settings.active_colorscheme or "default",
		},
		bypass = {
			options = true, -- Override global options
			keymaps = true, -- Override global keymaps
			autocmds = true, -- Override global autocmds
		},
		ai_tools = {
			enabled = false,
		},
	},
}
