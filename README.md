Avant d'importer ma config nvim avec chezmoi import nvim, je veux modifier le fichier README de mon dotfiles : https://github.com/ca971/dotfiles pour intégre ma config nvim dans mon dotfiles. Voici mon README actuel : # 🚀 ca971 Dotfiles

[![Commits: Verified](https://img.shields.io/badge/commits-verified-brightgreen.svg)](https://github.com/ca971/dotfiles/commits/main)
[![Security: SSH Signing](https://img.shields.io/badge/security-SSH--signing-blue.svg)](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Built with: chezmoi](https://img.shields.io/badge/built%20with-chezmoi-512bd4.svg)](https://www.chezmoi.io/)
[![Shell: Zsh](https://img.shields.io/badge/shell-zsh-brightgreen.svg)](https://www.zsh.org/)

> My automated development environment for **macOS** and **Linux**.  
> This repository turns a fresh machine into a professional, high-performance workstation in minutes.

---

## ✨ Core Highlights

This setup is engineered for speed, deep interactivity, and minimalist visual feedback.

### 🐚 Zsh & Powerlevel10k

- **Instant Prompt**: Near-zero loading time (0.1s) using P10k's optimization.
- **Fzf-tab**: Replaces the standard completion menu with a powerful fuzzy-search interface.
- **Auto-managed Plugins**: Optimized loading for `zsh-syntax-highlighting` and `zsh-autosuggestions` without shell bloat.

### 🔍 Fuzzy Everything (FZF)

- **CTRL-T**: Intelligent file search with dynamic previews (`bat` for code, `eza` for directories).
- **CTRL-R**: Full-text history search with a preview toggle.
- **Smart Completion**: Context-aware previews for `cd`, `kill`, `docker`, `systemd`, and `cat`.

### 🛠 Tools & Integrations

- **Mise**: Polyglot tool manager (Node, Python, Go, etc.).
- **Zoxide**: A smarter `cd` command that learns your habits.
- **Custom Workflows**: Interactive functions for **Docker** (`fdk`) and **Git** (`gff`, `gsi`, `glo`).
- **Modern CLI replacements**: `eza` (ls), `bat` (cat), `duf` (df), `btop` (top).

---

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

---

## 🤝 Contributing

Feel free to fork this repo, open issues, or submit PRs. Any contribution to make this environment faster or more elegant is welcome!

**Author:** [ca971](https://github.com/ca971)  
**License:** MIT
Peux-tu rajouter nvim avec toutes ses fonctionalités
