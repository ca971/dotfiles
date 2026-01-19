-- [[ UTILITIES PLUGINS ]]
local M = {}

-- [[ HELPER FUNCTIONS ]]
-- Check if a file path exists using uv (cross-platform)
local function path_exists(path)
	return (vim.uv or vim.loop).fs_stat(path) ~= nil
end

-- [[ PLUGIN GENERATION ]]
-- Generate plugin specifications for Lazy.nvim based on user profile and namespace
M.get_active_user_plugins = function(active_user)
	local specs = {}

	-- Determine the active namespace
	local namespace = Settings.enable_namespace and active_user.namespace or ""

	-- Function to add plugin specs if the path physically exists on disk
	local function add_plugins(path, import)
		if path_exists(path) then
			table.insert(specs, { import = import })
		end
	end

	-- [[ DEFAULT NAMESPACE LOGIC ]]
	-- Load plugins if no namespace is set
	if active_user.name:lower() ~= "noconfig" or Settings.enable_noconfig_lazyvim_plugins then
		if namespace == "" then
			if Settings.enable_lazyvim_plugins then
				-- Load LazyVim distribution
				table.insert(specs, {
					{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
					{ import = "lazyvim.plugins.extras.lang.json" },
					{ import = "lazyvim.plugins.extras.lang.typescript" },
				})
			else
				-- Load custom plugins for standard configuration
				table.insert(specs, {
					{ import = "plugins" },
					{ import = "plugins.themes" },
				})
				for _, group in ipairs(active_user.plugins) do
					table.insert(specs, { import = "plugins/" .. group })

					if group == "lang" then
						for _, lang in ipairs(active_user.lang or {}) do
							table.insert(specs, { import = "plugins/lang/" .. lang })
						end
					end
				end
			end
		end
	end

	-- [[ NAMESPACE LOGIC ]]
	-- Load plugins if a specific namespace is active (Multi-user setup)
	if namespace ~= "" then
		-- Load base plugins (Root)
		add_plugins(vim.fn.stdpath("config") .. "/lua/plugins", "plugins")
		add_plugins(vim.fn.stdpath("config") .. "/lua/plugins/themes", "plugins.themes")

		-- Load common plugins (Shared across users in this namespace)
		local common_path = vim.fn.stdpath("config") .. "/lua/plugins/common"
		add_plugins(common_path, "plugins.common")

		for _, group in ipairs(active_user.plugins) do
			local group_path = common_path .. "/" .. group
			add_plugins(group_path, "plugins.common." .. group)
		end

		-- Load namespace-specific plugins (User isolation)
		local namespace_path = vim.fn.stdpath("config") .. "/lua/plugins/_ns" .. "/" .. namespace
		add_plugins(namespace_path, "plugins._ns." .. namespace)

		for _, group in ipairs(active_user.plugins) do
			local group_path = namespace_path .. "/" .. group
			add_plugins(group_path, "plugins._ns." .. namespace .. "." .. group)
		end
	end

	-- [[ LANGUAGE PLUGINS ]]
	-- Load language-specific plugins based on the user's configuration
	for _, lang in ipairs(active_user.lang or {}) do
		-- Determine path based on whether a namespace is active
		local lang_path = namespace ~= ""
				and vim.fn.stdpath("config") .. "/lua/plugins._ns./" .. namespace .. "/lang/" .. lang
			or vim.fn.stdpath("config") .. "/lua/plugins/lang/" .. lang

		local import_path = namespace ~= "" and "plugins._ns." .. namespace .. ".lang." .. lang
			or "plugins.lang." .. lang
		add_plugins(lang_path, import_path)
	end

	return specs
end

return M
