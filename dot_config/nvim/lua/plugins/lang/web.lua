local M = {}

local default_options = {
	mode = Settings.enable_colorizer_mode, -- Display colors as virtual text
	css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
	virtualtext = "", -- Icon for virtual text
	virtualtext_inline = Settings.enable_colorizer_virtualtext_inline,
	always_update = true, -- Update colors dynamically
	sass = { enable = true, parsers = { "css" } }, -- Enable SASS colorization
	scss = { enable = true, parsers = { "css" } }, -- Enable SCSS colorization
}

-- Determine configuration based on colorizer_ft_enabled
local setup_config = not Settings.enable_colorizer_ft
		and {
			"*", -- Highlight all files
			"!vim", -- Exclude Vim-specific files
			user_default_options = default_options,
		}
	or {
		filetypes = {
			"css",
			"scss",
			"less",
			html = { mode = "background" },
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
		user_default_options = default_options,
	}

M.setup = function()
	local colorizer = require("colorizer")
	colorizer.setup(setup_config)
end

return {
	-- Css colors
	{
		"NvChad/nvim-colorizer.lua",
		event = "BufReadPre",
		cmd = {
			"ColorizerAttachToBuffer",
			"ColorizerDetachFromBuffer",
			"ColorizerReloadAllBuffers",
			"ColorizerToggle",
		},
		config = function()
			M.setup()
		end,
	},

	-- {
	-- 	"NvChad/nvim-colorizer.lua",
	-- 	event = "BufReadPre",
	-- 	opts = {
	-- 		filetypes = { "*", "!lazy", "!neo-tree" },
	-- 		buftype = { "*", "!prompt", "!nofile" },
	-- 		user_default_options = {
	-- 			RGB = true, -- #RGB hex codes
	-- 			RRGGBB = true, -- #RRGGBB hex codes
	-- 			names = false, -- "Name" codes like Blue
	-- 			RRGGBBAA = true, -- #RRGGBBAA hex codes
	-- 			AARRGGBB = false, -- 0xAARRGGBB hex codes
	-- 			rgb_fn = true, -- CSS rgb() and rgba() functions
	-- 			hsl_fn = true, -- CSS hsl() and hsla() functions
	-- 			css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
	-- 			css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
	-- 			-- Available modes: foreground, background
	-- 			-- Available modes for `mode`: foreground, background,  virtualtext
	-- 			mode = "background", -- Set the display mode.
	-- 			virtualtext = "■",
	-- 		},
	-- 	},
	-- },
}
