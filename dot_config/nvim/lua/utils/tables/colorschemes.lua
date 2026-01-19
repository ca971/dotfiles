-- [[ COLORSCHEMES DEFINITIONS ]]
-- Define repository, dependencies, and theme variants for supported colorschemes.
-- The 'enabled' key is controlled by the Settings table.
local Settings = require("settings")

return {
	-- Catppuccin themes
	catppuccin = {
		repo = "catppuccin/nvim",
		dependencies = {},
		name = "catppuccin",
		themes = { "catppuccin-macchiato", "catppuccin-latte", "catppuccin-frappe", "catppuccin-mocha" },
		enabled = Settings.enable_catppuccin,
	},
	-- Tokyo Night themes
	tokyonight = {
		repo = "folke/tokyonight.nvim",
		dependencies = {},
		name = "tokyonight",
		themes = { "tokyonight-night", "tokyonight-storm", "tokyonight-day", "tokyonight-moon" },
		enabled = Settings.enable_tokyonight,
	},
	-- Kanagawa themes
	kanagawa = {
		repo = "rebelot/kanagawa.nvim",
		dependencies = {},
		name = "kanagawa",
		themes = { "kanagawa-wave", "kanagawa-dragon", "kanagawa-lotus" },
		enabled = Settings.enable_kanagawa,
	},
	-- Nightfox themes
	nightfox = {
		repo = "EdenEast/nightfox.nvim",
		dependencies = {},
		name = "nightfox",
		themes = { "nightfox", "carbonfox", "dawnfox", "dayfox", "duskfox", "nordfox", "terafox" },
		enabled = Settings.enable_nightfox,
	},
	-- Gruvbox themes
	gruvbox = {
		repo = "ellisonleao/gruvbox.nvim",
		dependencies = {},
		name = "gruvbox",
		themes = { "gruvbox" },
		enabled = Settings.enable_gruvbox,
	},
	-- OneDark Pro themes
	["onedark-pro"] = {
		repo = "olimorris/onedarkpro.nvim",
		dependencies = {},
		name = "onedarkpro",
		themes = { "onelight", "onedark", "onedark_vivid", "onedark_dark" },
		enabled = Settings.enable_onedark_pro,
	},
	-- Monokai Pro themes
	["monokai-pro"] = {
		repo = "tanvirtin/monokai.nvim",
		dependencies = {},
		name = "monokai_pro",
		themes = { "monokai", "monokai_pro", "monokai_soda", "monokai_ristretto" },
		enabled = Settings.enable_monokai_pro,
	},
	-- Dracula themes
	dracula = {
		repo = "Mofiqul/dracula.nvim",
		dependencies = {},
		name = "dracula",
		themes = { "dracula", "dracula-soft" },
		enabled = Settings.enable_dracula,
	},
	-- Nightfly themes
	nightfly = {
		repo = "bluz71/vim-nightfly-colors",
		dependencies = {},
		name = "nightfly",
		themes = { "nightfly" },
		enabled = Settings.enable_nightfly,
	},
	-- Cyberdream themes
	cyberdream = {
		repo = "scottmckendry/cyberdream.nvim",
		dependencies = {},
		name = "cyberdream",
		themes = { "cyberdream" },
		enabled = Settings.enable_cyberdream,
	},
	-- Night Owl themes
	["night-owl"] = {
		repo = "oxfist/night-owl.nvim",
		dependencies = {},
		name = "night-owl",
		themes = { "night-owl" },
		enabled = Settings.enable_night_owl,
	},
	-- Solarized Osaka themes
	["solarized-osaka"] = {
		repo = "craftzdog/solarized-osaka.nvim",
		dependencies = {},
		name = "solarized-osaka",
		themes = { "solarized-osaka" },
		enabled = Settings.enable_solarized_ozaka, -- Corrected typo from 'solrized'
	},
	-- Zenbones themes
	zenbones = {
		repo = "zenbones-theme/zenbones.nvim",
		dependencies = "rktjmp/lush.nvim",
		name = "zenbones",
		themes = {
			"zenwritten",
			"neobones",
			"vimbones",
			"rosebones",
			"forestbones",
			"nordbones", -- Removed accidental tab character
			"tokyobones",
			"seoulbones",
			"duckbones",
			"zenburned",
			"kanagawabones",
			"randombones",
		},
		enabled = Settings.enable_zenbones,
	},
	-- Yorumi themes
	yorumi = {
		repo = "yorumicolors/yorumi.nvim",
		dependencies = {},
		name = "yorumi",
		themes = {
			"yorumi",
			"yorumi-abyss",
		},
		enabled = Settings.enable_yorumi,
	},
	-- Shadow themes
	shadow = {
		repo = "rjshkhr/shadow.nvim",
		dependencies = {},
		name = "shadow",
		themes = { "shadow" },
		enabled = Settings.enable_shadow,
	},
}
