## 🚀 What's Changed in v1.0.0

Major architectural refactoring to move towards a true modular and multi-user environment.

### ⚡ Core Architecture
- **OOP Implementation**: Introduced a robust `Env` singleton in `core/env.lua` to manage OS detection, paths, and module loading centrally.
- **Modular Design**: Separated concerns into `Lib` (utils), `Settings` (config), and `Env` (state).
- **Namespace Support**: Added multi-user/environment isolation (`_ns/bly`, `_ns/free`).
- **Directory Management**: Automatic creation of cache folders (`undo`, `swap`, `backup`) based on `settings.lua`.

### 🎨 User Interface
- **New Dashboard**: Replaced legacy dashboard with `folke/snacks.nvim`.
 
### 🔧 Developer Tools
- **LSP Management**:
  - `mason-lspconfig`: Refined `ensure_installed` list (using centralized `servers.lua` table).
  - `conform.nvim`: Added for formatting with LSP fallback.
  - Auto-installation: LSP servers install automatically when a file is opened.

### ⚠️ Breaking Changes / Migration
- **Variable Scope**: Global variables like `Settings` (capital S) have been encapsulated into `Env.settings`. All plugins must now use `Env.settings...` to access configuration.

### 🐛 Bug Fixes
- Resolved `table index is nil` errors by using dot notation or `Lib.tbl_get`.
- Fixed `vim.g.mapleader` warnings by ensuring `Env:set_leaders()` runs before `lazy.nvim` loads.
