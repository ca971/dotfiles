
[![Architecture: Modular](https://img.shields.io/badge/Architecture-Modular-orange)](https://github.com/ca971/dotfiles)
[![Made with: Lua](https://img.shields.io/badge/Made%20with-Lua-blue.svg?logo=lua)](https://www.lua.org/)
[![Built with: chezmoi](https://img.shields.io/badge/built%20with-chezmoi-512bd4.svg)](https://www.chezmoi.io/)
[![Built with: Neovim](https://img.shields.io/badge/Built%20with-Neovim-57A143?logo=neovim&logoColor=white)](https://neovim.io/)
[![Commits: Verified](https://img.shields.io/badge/commits-verified-brightgreen.svg)](https://github.com/ca971/dotfiles/commits/main)
[![Security: SSH Signing](https://img.shields.io/badge/security-SSH--signing-blue.svg)](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)
[![Shell: Zsh](https://img.shields.io/badge/shell-zsh-brightgreen.svg)](https://www.zsh.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Maintained: Yes](https://img.shields.io/badge/Maintained-Yes-green.svg)](https://github.com/ca971/dotfiles)


<h4 align="center">
    This configuration is engineered for speed, modularity, and deep interactivity.
</h4>

<div align="center>"
<h4 align="center">
    <a href="https://github.com/ca971">Projects</a>
     ·
    <a href="https://github.com/ca971/dotfiles?tab=readme-ov-file#%EF%B8%8F-quick-start">Install</a>
     ·
    <a href="https://github.com/ca971/dotfiles?tab=readme-ov-file#-neovim--lazy-oop-architecture>Architecture</a>
</h4>
</div>


![image](https://github.com/ca971/dotfiles/blob/main/dot_config/nvim/static/screenshot.png)

![image](https://github.com/ca971/dotfiles/blob/main/dot_config/nvim/static/screencode.png)


## ✨ Core Highlights

### ⚡ Neovim & Lazy (OOP Architecture)
A Lua configuration built around a robust **Singleton** architecture.
*   **Instant Startup**: Bootstraps instantly using `vim.uv` and an `Env` singleton to manage environment variables (OS, paths, user profiles).
*   **Modular Design**: Configuration is split into logical modules (`Env`, `Lib`, `Settings`), ensuring code reusability and clean separation of concerns.
*   **Namespace Support**: Multi-environment isolation (e.g., `bly`, `free`) allows different users/machines to have distinct plugin sets and overrides without conflict.
*   **Intelligent Tooling**: Mason integration with "lazy provisioning". LSP servers are **auto-installed on-demand** when opening a specific file type (e.g., opening a `.py` file automatically installs `pyright`), keeping the environment lightweight.

### 🎨 Snacks.nvim (Modern UI)
A unified, high-performance replacement for multiple core plugins.
*   **Smart Dashboard**: Features a custom ASCII greeting based on time of day, quick actions, and project history.
*   **Zen Mode**: Distraction-free coding environment with intelligent toggles (diagnostics, git signs).
*   **Enhanced Notifications**: Rich notifications for LSP diagnostics, command history, and system events.
*   **Integrated Workflow**: Seamless integration with LazyGit and session management directly from the dashboard.

### 🐚 Zsh & Powerlevel10k
*   **Instant Prompt**: Near-zero loading time (0.1s) using P10k's optimization.
*   **Fzf-tab**: Replaces standard completion menu with a powerful fuzzy-search interface.
*   **Auto-managed Plugins**: Optimized loading for `zsh-syntax-highlighting` and `zsh-autosuggestions`.

### 🔍 Fuzzy Everything
*   **CTRL-T**: Intelligent file search with dynamic previews (`bat` for code, `eza` for directories).
*   **CTRL-R**: Full-text history search with a preview toggle.
*   **Smart Completion**: Context-aware previews for `cd`, `kill`, `docker`, `systemd`, and `cat`.

### 🛠 Tools & Integrations
*   **Mise**: Polyglot tool manager (Node, Python, Go, etc.).
*   **Zoxide**: A smarter `cd` command that learns your habits.
*   **Custom Workflows**: Interactive functions for **Docker** (`fdk`) and **Git** (`gff`, `gsi`, `glo`).
*   **Modern CLI replacements**: `eza` (ls), `bat` (cat), `duf` (df), `btop` (top).


## ⚡️ Quick Start

**Warning:** This script installs dependencies via Homebrew and configures your environment.

```bash
curl -L https://dub.sh/hg67BHh | bash
```

### 📌 [!TIP] Alternative install link

```bash
curl -L https://is.gd/tXKWf1 | bash
```

### 🧑🏽‍🔧 Manual installation

if you prefer to install manually using chezmoi:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ca971
```

## 📖 Key Shortcuts

| Alias/Key | Action            | Description                                            |
| :-------- | :---------------- | :----------------------------------------------------- |
| `gff`     | **Git Find File** | Search and open tracked files using FZF & Neovim.      |
| `fdk`     | **Fuzzy Docker**  | Interactively manage containers (Logs, Stop, Shell).   |
| `glo`     | **Git Graph**     | Visual git history with commit content preview.        |
| `fcd`     | **Fuzzy CD**      | Interactive directory navigation with tree preview.    |
| `edot`    | **Edit Dotfiles** | Modify config and apply changes instantly via Chezmoi. |


### ⚡️ Neovim

| Key/Command | Action          | Description                                              |
| :---------- | :-------------- | :------------------------------------------------------- |
| `<space>`   | **Leader Key**  | Prefix for all custom mappings.                           |
| `<leader>e`  | **Explorer**    | Toggle Neo-tree (File Explorer).                          |
| `<leader>ff` | **Find File**   | Search files using Telescope.                             |
| `<leader>fg` | **Live Grep**   | Search text content in project (Telescope).                |
| `<leader>gg` | **LazyGit**    | Open LazyGit UI (checks for unsaved buffers first).        |
| `<leader>mp` | **Format**      | Format current file or selection (Conform.nvim).           |
| `<leader>uz` | **Zen Mode**    | Toggle Zen mode (Snacks.nvim).                            |
| `<c-t>`      | **Terminal**     | Toggle floating terminal (Snacks.nvim).                     |
| `<c-space>`   | **Flash**       | Jump to location by label (Flash.nvim).                    |
| `gd`         | **Definition**  | Go to definition (LSP).                                  |
| `K`          | **Hover**       | Show documentation popup (LSP).                            |

---

## 🤝 Contributing

Feel free to fork this repo, open issues, or submit PRs. Any contribution to make this environment faster or more elegant is welcome!

**Author:** [ca971](https://github.com/ca971)  
**License:** MIT
