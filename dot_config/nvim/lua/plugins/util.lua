-- [[ UTILITIES ]]
return {
	-- [[ CORE LIBRARY ]]
	-- General-purpose Lua library used by many other plugins
	{ "nvim-lua/plenary.nvim", lazy = true },

	-- [[ SESSION MANAGEMENT ]]
	-- Saves your session in the background, keeping track of open buffers,
	-- window arrangement, and more. Allows restoring sessions when returning
	-- via the dashboard.
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>ss", function() require("persistence").load() end,                desc = "Restore Session" },
      { "<leader>sS", function() require("persistence").select() end,              desc = "Select Session" },
      { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>sd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
    },
	},
}
