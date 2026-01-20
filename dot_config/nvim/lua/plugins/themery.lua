-- [[ THEMERY PLUGIN ]]
-- Live preview and switch between available colorschemes

-- [[ HELPER FUNCTIONS ]]
-- Retrieve all available themes from the colorschemes table
local function get_all_available_themes()
  -- Load all colorschemes
  local colorschemes = Env.utils.tables.colorschemes

  local themes = {}
  for _, scheme in pairs(colorschemes) do
    if scheme.themes and type(scheme.themes) == "table" then
      vim.list_extend(themes, scheme.themes)
    end
  end

  return themes
end

return {
  "zaldih/themery.nvim",
  cmd = "Themery",
  name = "themery",
  keys = { "<leader>um" },
  config = function()
    require("themery").setup({
      -- Dynamically set the default theme based on active user's settings
      default_theme = Env.settings.active_colorscheme,
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = "italic",
        keywords = "bold",
        functions = "italic",
      },
      livePreview = true,

      -- Pass the pre-computed table of themes
      themes = get_all_available_themes(),
    })
  end,
}
