-- [[ COLORSCHEMES PLUGINS ]]
local colorschemes = Env.utils.tables.colorschemes
local user_colorscheme = Env.utils.tables.active_user.colorscheme or {}

-- [[ ACTIVE THEME RESOLUTION ]]
-- Retrieve the name of the active colorscheme and the specific variant (theme)
local active_colorscheme = user_colorscheme.name or "default"
local active_theme = user_colorscheme.theme

-- [[ PLUGIN SPECS GENERATION ]]
-- Container for the plugin specifications
local specs = {}

-- Iterate through all defined colorschemes to generate Lazy specs
for name, scheme in pairs(colorschemes) do
	local is_active = name == active_colorscheme

	table.insert(specs, {
		scheme.repo,
		name = name,
		enabled = scheme.enabled,
		-- Lazy load unless it is the active colorscheme
		lazy = not is_active,
		-- Set high priority for the active colorscheme to ensure it loads early
		priority = is_active and 1000 or nil,
		-- Include required dependencies
		dependencies = scheme.dependencies or {},

		-- [[ THEME CONFIGURATION ]]
		config = function()
			if is_active then
				-- Determine the specific theme variant to apply
				-- Validate if the requested 'active_theme' exists in the scheme's list
				local theme_to_apply = active_theme and vim.tbl_contains(scheme.themes, active_theme) and active_theme
					or name

				-- Apply the colorscheme
				vim.cmd.colorscheme(theme_to_apply)

				-- [[ FALLBACK NOTIFICATION ]]
				-- Notify if the requested variant was not found
				if theme_to_apply ~= active_theme then
					vim.notify(
						("Theme '%s' not found for '%s'. Falling back to '%s'."):format(
							active_theme or "nil",
							name,
							theme_to_apply
						),
						vim.log.levels.WARN
					)
				end
			end
		end,
	})
end

-- [[ RETURN SPECS ]]
-- Return plugin specs only if colorschemes are enabled in settings
return Env.settings.enable_colorschemes and specs or {}
