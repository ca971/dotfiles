## 🚀 What's Changed in v1.0.0

Major architectural refactoring to move towards a true "Power User" environment.

### ⚡ Core Architecture
- **OOP Implementation**: Introduced a robust `Env` singleton in `core/env.lua` to manage OS detection, paths, and module loading centrally.
- **Modular Design**: Separated concerns into `Lib` (utils), `Settings` (config), and `Env` (state).
- **Namespace Support**: Added multi-user/environment isolation (`_ns/bly`, `_ns/free`).
- **Directory Management**: Automatic creation of cache folders (`undo`, `swap`, `backup`) based on `settings.lua`.

### 🎨 User Interface
- **New Dashboard**: Replaced legacy dashboard with `folke/snacks.nvim`.
  - Custom ASCII header support (Time-based greeting).
  - Integrated LazyGit with unsaved buffers check.
  - Unified Terminal and Session management.
- **Visual Polish**: Rounded borders for UI elements, consistent styling.
- **Colorizer**: Added `vim.opt.viewdir` and persistent cache folders.

### 🔧 Developer Tools
- **LSP Management**:
  - `mason-lspconfig`: Refined `ensure_installed` list (using centralized `servers.lua` table).
  - `conform.nvim`: Added for formatting with LSP fallback.
  - Auto-installation: LSP servers install automatically when a file is opened.
- **Treesitter**: Configured to load essential parsers immediately and optional parsers on-demand.

### ⚠️ Breaking Changes / Migration
- **Settings Migration**: If you were using the old `utils/tables/servers.lua` structure, this data has been moved into `lua/settings.lua`.
- **Variable Scope**: Global variables like `Settings` (capital S) have been encapsulated into `Env.settings`. All plugins must now use `Env.settings...` to access configuration.
- **File Organization**: `plugins/common` has been deprecated in favor of `plugins/_ns/{name}`.

### 🐛 Bug Fixes
- Fixed `Settings` variable nil errors in `core/lazy.lua`.
- Resolved `table index is nil` errors by using dot notation or `Lib.tbl_get`.
- Fixed `vim.g.mapleader` warnings by ensuring `Env:set_leaders()` runs before `lazy.nvim` loads.

---

**Full Changelog**: https://github.com/ca971/dotfiles/compare/v0.9.0...v1.0.0
