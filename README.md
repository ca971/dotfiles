<div align="center">

# 🔧 Dotfiles Enterprise

**Cross-Platform · Cross-Shell · SSOT Architecture · Security-Hardened ·
Power-User Grade**

A meticulously engineered, production-ready dotfiles framework built on Single
Source of Truth principles for maximum consistency, security, and
maintainability across all platforms and shells.

<br/>

[![Shell](https://img.shields.io/badge/Shell-ZSH%20·%20Bash%20·%20Fish%20·%20Nushell-green?style=for-the-badge&logo=gnubash&logoColor=white)](#-cross-shell-support)
[![Platform](https://img.shields.io/badge/Platform-macOS%20·%20Linux%20·%20WSL-E95420?style=for-the-badge&logo=linux&logoColor=white)](#-cross-platform-support)
[![License](https://img.shields.io/badge/License-MIT-F7DF1E?style=for-the-badge)](./LICENSE)
[![Tools](https://img.shields.io/badge/Tools-60%2B-blue?style=for-the-badge&logo=hackthebox&logoColor=white)](#-integrated-tools)
[![Terminals](https://img.shields.io/badge/Terminals-5-purple?style=for-the-badge&logo=windowsterminal&logoColor=white)](#-terminal--editor-management)

[![Startup](https://img.shields.io/badge/Startup-%3C%20500ms-ff6b6b?style=flat-square&logo=speedtest&logoColor=white)](#-performance)
[![Themes](https://img.shields.io/badge/Starship-3%20Themes-purple?style=flat-square&logo=starship&logoColor=white)](#-starship-themes)
[![Security](https://img.shields.io/badge/Security-Hardened-success?style=flat-square&logo=letsencrypt&logoColor=white)](#-security)
[![SSOT](https://img.shields.io/badge/SSOT-TOML%20→%204%20Shells-orange?style=flat-square&logo=toml&logoColor=white)](#-ssot-architecture)
[![Maintained](https://img.shields.io/badge/Status-Active-success?style=flat-square)](https://github.com/ca971/dotfiles)

<br/>

[Features](#-key-features) • [Install](#-installation) •
[Architecture](#-architecture) • [CLI](#-dot-cli) • [Tools](#-integrated-tools)
• [Security](#-security) • [Wiki](https://github.com/ca971/dotfiles/wiki)

</div>

---

## 📑 Table of Contents

<details>
<summary><strong>Click to expand</strong></summary>

- [💎 The Enterprise Edge](#-the-enterprise-edge)
- [✨ Core Philosophy](#-core-philosophy)
- [🚀 Key Features](#-key-features)
- [🌍 Cross-Platform Support](#-cross-platform-support)
- [🐚 Cross-Shell Support](#-cross-shell-support)
- [📦 Requirements](#-requirements)
- [🔧 Installation](#-installation)
- [📐 Architecture](#-architecture)
- [🎯 SSOT Architecture](#-ssot-architecture)
- [🔧 dot CLI](#-dot-cli)
- [🎨 Starship Themes](#-starship-themes)
- [🛠️ Integrated Tools](#-integrated-tools)
- [🔐 Security](#-security)
- [🔑 SSH Management](#-ssh-management)
- [📝 Git Integration](#-git-integration)
- [⚡ Performance](#-performance)
- [🧪 Testing](#-testing)
- [📄 License](#-license)

</details>

---

## 💎 The Enterprise Edge

> **Dotfiles Enterprise** isn't just another dotfile collection — it's a
> **structured ecosystem** built on enterprise-grade engineering principles:
> SSOT, modularity, security, and cross-platform reproducibility.

Whether you're a solo developer, a DevOps engineer managing infrastructure, or a
power user who lives in the terminal — **Dotfiles Enterprise scales with your
needs**.

```
┌──────────────────────────────────────────────────────────────────┐
│                   Dotfiles Enterprise Stack                      │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────────────┐   │
│  │  Shells  │  │  Tools   │  │  Config  │  │    Security     │   │
│  │ ZSH·Bash │  │   60+    │  │  SSOT    │  │  SSH·GPG·Keys   │   │
│  │Fish·Nu   │  │ per-file │  │  TOML    │  │  Signing·Audit  │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬──────────┘   │
│       │              │             │               │             │
│  ┌────▼──────────────▼─────────────▼───────────────▼──────────┐  │
│  │           shared/ — POSIX env · PATH · tools-init          │  │
│  └────────────────────────────┬───────────────────────────────┘  │
│                               │                                  │
│  ┌────────────────────────────▼───────────────────────────────┐  │
│  │        SSOT Layer (aliases.toml · colors · icons)          │  │
│  │      generators → .zsh · .bash · .fish · .nu               │  │
│  └────────────────────────────┬───────────────────────────────┘  │
│                               │                                  │
│  ┌────────────────────────────▼───────────────────────────────┐  │
│  │      Platform Layer (macOS · Linux · WSL · Arch · Deb)     │  │
│  └────────────────────────────┬───────────────────────────────┘  │
│                               │                                  │
│  ┌────────────────────────────▼───────────────────────────────┐  │
│  │   Terminal Layer (Ghostty · WezTerm · Kitty · Alacritty)   │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

---

## ✨ Core Philosophy

| Principle             | Description                                                      |
| :-------------------- | :--------------------------------------------------------------- |
| 🎯 **SSOT**           | Define once in TOML, generate for all shells — zero duplication  |
| 🔒 **Secure**         | SSH hardening, GPG integration, secrets management, key rotation |
| 🌍 **Cross-Platform** | macOS, Linux, WSL — auto-detected, auto-configured               |
| 🐚 **Cross-Shell**    | ZSH, Bash, Fish, Nushell — shared config, native syntax          |
| ⚡ **Blazing Fast**   | Lazy loading, turbo mode, background compilation — < 500ms       |
| 🧩 **Modular**        | One tool = one file. Config separated from code                  |
| 🔧 **Zero Manual**    | Everything auto-configures on first launch. No `mkdir` needed    |
| 📋 **Documented**     | JSDoc-style comments, complete README, help for every command    |

---

## 🚀 Key Features

<table>
<tr>
<td width="50%" valign="top">

### 🎯 SSOT Architecture

- **TOML → 4 shells**: aliases, colors, icons, highlights
- Generators transpile TOML to ZSH, Bash, Fish, Nushell
- Change once → regenerate → all shells updated
- `config/tools.d/` for per-tool customization
- `ssot/aliases.toml` for generic shell aliases

</td>
<td width="50%" valign="top">

### 🐚 Multi-Shell Support

- **ZSH** — Full-featured with Zinit plugins, completions
- **Bash** — Lightweight, sources shared env + SSOT aliases
- **Fish** — Native abbreviations, FZF integration
- **Nushell** — Structured data, custom commands
- Shared env vars via `shells/shared/env.sh`

</td>
</tr>
<tr>
<td width="50%" valign="top">

### 🔐 Security First

- SSH config modulaire (`config.d/`) with hardened defaults
- Dynamic key management — discover all `id_*` automatically
- macOS Keychain integration — silent passphrase
- GPG integration — agent, signing, key management
- Git commit signing (SSH keys, GitHub compatible)
- Encrypted key backup (age/GPG)
- `ssh-audit` security health check

</td>
<td width="50%" valign="top">

### 🛠️ 60+ Tool Integrations

- Each tool: `tools/TOOL.zsh` (code) + `config/tools.d/TOOL.zsh` (config)
- Auto-setup: clone repos, create symlinks, generate configs
- Conditional loading: tool not installed = nothing loaded
- FZF integration everywhere — interactive selection
- `dot` CLI — unified management interface

</td>
</tr>
<tr>
<td width="50%" valign="top">

### 🎨 Starship Prompt — 3 Themes

- **Powerline** — Full-featured, workstation default
- **Minimal** — Clean, for SSH/Docker/remote
- **Nerd** — Maximum info, VPS/Proxmox/K8s
- Auto-selected based on context (SSH, container, VPS)
- Runtime switching: `dot theme minimal`

</td>
<td width="50%" valign="top">

### 📦 Auto-Clone Configs

- **nvim-enterprise** → `~/.config/nvim`
- **wezterm-enterprise** → `~/.config/wezterm`
- **ghostty-config** → `~/.config/ghostty`
- **git-templates** → `dotfiles/config/git/git-templates`
- Background updates on every shell startup

</td>
</tr>
</table>

---

## 🌍 Cross-Platform Support

> Automatic detection via `lib/platform-detect.zsh` — zero manual configuration.

| Platform           | Status | Package Manager     | Module                 |
| :----------------- | :----: | :------------------ | :--------------------- |
| 🍎 macOS           |   ✅   | Homebrew            | `platform/darwin.zsh`  |
| 🐧 Ubuntu / Debian |   ✅   | apt                 | `platform/debian.zsh`  |
| 🎩 Fedora / RHEL   |   ✅   | dnf                 | `platform/fedora.zsh`  |
| 🏔️ Arch / Manjaro  |   ✅   | pacman / paru / yay | `platform/arch.zsh`    |
| 🪟 WSL / WSL2      |   ✅   | apt / dnf / pacman  | `platform/wsl.zsh`     |
| ❄️ NixOS           |   ✅   | nix                 | `core/01-platform.zsh` |

---

## 🐚 Cross-Shell Support

| Shell       | Config            | Aliases        | Tool Inits             | Prompt   |
| :---------- | :---------------- | :------------- | :--------------------- | :------- | -------- |
| **ZSH**     | `shells/zsh/`     | SSOT + tools.d | `tools/*.zsh`          | Starship |
| **Bash**    | `shells/bash/`    | SSOT generated | `shared/tools-init.sh` | Starship |
| **Fish**    | `shells/fish/`    | SSOT generated | Native `| source`  | Starship |
| **Nushell** | `shells/nushell/` | Custom `def`   | Pre-generated `.nu`    | Starship |

---

## 📦 [Requirements](requirements.md)

| Dependency                              | Version  | Required |
| :-------------------------------------- | :------: | :------: |
| [Git](https://git-scm.com/)             | `≥ 2.40` |    ✅    |
| [ZSH](https://www.zsh.org/)             | `≥ 5.8`  |    ✅    |
| [Nerd Font](https://www.nerdfonts.com/) |   v3+    |    ✅    |
| [Homebrew](https://brew.sh/) (macOS)    |  latest  |    ⚠️    |

<details>
<summary><strong>📋 Install all tools</strong></summary>

```bash
brew install \
  eza fzf bat fd ripgrep zoxide starship delta atuin mise direnv \
  neovim git gh just tldr navi fastfetch btop dust duf topgrade \
  thefuck yazi carapace lazygit lazydocker most \
  jq yq gum age sd ouch glow xh hyperfine tokei procs \
  tmux zellij k9s dive curlie bandwhich difftastic broot viddy lnav \
  act trivy sops gnupg pinentry-mac git-lfs nushell

# Essential
brew install eza fzf bat fd ripgrep zoxide starship delta atuin mise direnv neovim git

# DevOps
brew install docker podman kubectl helm k9s lazygit lazydocker dive act trivy sops ansible

# Utilities
brew install gh just tldr navi fastfetch btop dust duf topgrade thefuck yazi carapace most

# Data & HTTP
brew install jq yq gum xh curlie

# Security
brew install age gnupg pinentry-mac git-lfs

# Performance & Analysis
brew install hyperfine tokei procs bandwhich difftastic

# File & System
brew install sd ouch glow broot viddy lnav

# Multiplexers
brew install tmux zellij

# Shells
brew install bash fish nushell

# Terminals
brew install --cask ghostty wezterm kitty alacritty
```

</details

---

## 🔧 Installation

### One-Line Install

```bash
git clone https://github.com/ca971/dotfiles.git ~/dotfiles && sh ~/dotfiles/bootstrap.sh
```

### Manual

```bash
# Clone
git clone https://github.com/ca971/dotfiles.git ~/dotfiles

# Bootstrap (detects shells, creates symlinks, generates SSOT)
sh ~/dotfiles/bootstrap.sh

# Or step by step
cd ~/dotfiles
just link              # Create symlinks
just generate-all      # Generate SSOT files
exec zsh               # Restart shell
```

### Post-Install

```bash
dot doctor             # Health check
dot tools              # Tool availability
dot shells             # Shell status
dot ssh audit          # SSH security audit
dot benchmark 5        # Startup benchmark
```

---

## 📐 [Architecture](architecture.md)

```
~/dotfiles/
├── bin/                            # CLI tools
│   ├── dot                         # Unified CLI dispatcher
│   └── dot.d/                      # CLI modules
│       ├── _core.sh                # SSOT colors, icons, helpers
│       ├── help.sh                 # dot help
│       ├── info.sh                 # dot info
│       ├── status.sh               # dot status
│       ├── theme.sh                # dot theme
│       ├── ssh.sh                  # dot ssh
│       ├── ...                     # One module per command group
│
├── shells/                         # Shell-specific configurations
│   ├── shared/                     # Shared across all shells
│   │   ├── env.sh                  # POSIX env vars (SSOT)
│   │   ├── path.sh                 # PATH construction (SSOT)
│   │   └── tools-init.sh           # Tool init dispatcher
│   ├── zsh/                        # ZSH-specific
│   │   ├── .zshenv                 # Entry point (symlink ~/.zshenv)
│   │   ├── .zshrc                  # Main orchestrator
│   │   ├── core/                   # Options, history, completion, keys
│   │   ├── plugins/                # Zinit plugin management
│   │   └── terminal/               # Terminal adaptations (Ghostty, etc.)
│   ├── bash/.bashrc                # Bash config
│   ├── fish/config.fish            # Fish config
│   └── nushell/{env,config}.nu     # Nushell config
│
├── ssot/                           # Single Source of Truth (TOML)
│   ├── aliases.toml                # Generic aliases → 4 shell formats
│   ├── colors.toml                 # Color palette (Catppuccin)
│   ├── icons.toml                  # Nerd Font icons
│   ├── highlights.toml             # Syntax highlighting rules
│   ├── settings.toml               # Feature flags & parameters
│   ├── tools.toml                  # Tool registry
│   └── generators/                 # TOML → shell transpilers
│
├── generated/                      # Auto-generated (gitignored)
│   ├── aliases.{zsh,bash,fish,nu}  # Aliases per shell
│   ├── colors.zsh                  # Color variables
│   ├── icons.zsh                   # Icon constants
│   └── highlights.zsh              # Highlighting rules
│
├── config/                         # Tool configurations (versioned)
│   ├── git/                        # .gitconfig, .gitignore_global, etc.
│   ├── ssh/                        # SSH config.d/ templates
│   ├── gpg/                        # gpg.conf, gpg-agent.conf
│   ├── topgrade/                   # topgrade.toml
│   ├── bat/                        # bat config
│   ├── ripgrep/                    # ripgrep config
│   ├── fd/                         # fd ignore patterns
│   └── tools.d/                    # Per-tool aliases & options
│       ├── eza.zsh                 # Eza aliases
│       ├── git.zsh                 # Git aliases
│       ├── docker.zsh              # Docker aliases
│       ├── kubernetes.zsh          # K8s aliases
│       └── ...                     # 30+ tool configs
│
├── tools/                          # Tool integrations (code)
│   ├── git.zsh                     # Git auto-setup, functions
│   ├── ssh.zsh                     # SSH auto-setup, key management
│   ├── docker.zsh                  # Docker/Podman runtime detection
│   ├── neovim.zsh                  # Auto-clone nvim-enterprise
│   └── ...                         # 50+ tool integrations
│
├── functions/                      # Custom shell functions
│   ├── _helpers.zsh                # Clipboard, strings, dates
│   ├── archive.zsh                 # Extract/compress (20+ formats)
│   ├── git-helpers.zsh             # Git workflows
│   ├── network.zsh                 # IP, DNS, HTTP utilities
│   └── ...                         # 10 function modules
│
├── platform/                       # Platform-specific
│   ├── darwin.zsh                  # macOS (Homebrew, Finder, etc.)
│   ├── linux.zsh                   # Linux (systemd, clipboard)
│   ├── wsl.zsh                     # WSL interop
│   ├── arch.zsh                    # Arch (pacman/paru/yay)
│   ├── debian.zsh                  # Debian/Ubuntu (apt)
│   └── fedora.zsh                  # Fedora (dnf)
│
├── themes/                         # Prompt & color themes
│   ├── starship-powerline.toml     # Workstation prompt
│   ├── starship-minimal.toml       # SSH/Docker prompt
│   ├── starship-nerd.toml          # VPS/K8s prompt
│   ├── starship-selector.sh        # Auto-select (POSIX)
│   ├── starship-selector.zsh       # ZSH wrapper
│   └── fzf-theme.zsh              # FZF color themes (7 presets)
│
├── lib/                            # Internal libraries
│   ├── logging.zsh                 # Structured logging
│   ├── platform-detect.zsh         # OS/terminal detection
│   ├── tool-check.zsh              # Tool availability
│   ├── lazy-load.zsh               # Deferred loading
│   └── toml-parser.zsh             # TOML parser
│
├── local/                          # Private (gitignored)
│   ├── local.zsh                   # Machine-specific overrides
│   ├── secrets.zsh                 # API keys, tokens
│   ├── gitconfig.local             # Git identity
│   └── ssh_config_*.conf           # Private SSH hosts
│
├── scripts/                        # Maintenance scripts
│   ├── install.sh                  # Installer
│   ├── doctor.sh                   # Health check
│   ├── benchmark.zsh               # Startup profiler
│   └── update.sh                   # Self-updater
│
├── tests/                          # Test suites
├── bootstrap.sh                    # Universal bootstrap (POSIX sh)
├── Justfile                        # Task runner
├── README.md                       # This file
└── LICENSE                         # MIT
```

---

## 🎯 SSOT Architecture

Define configuration **once** in TOML, generate for **all shells**:

| TOML Source       | Generated Outputs            | Purpose                              |
| ----------------- | ---------------------------- | ------------------------------------ |
| `aliases.toml`    | `aliases.{zsh,bash,fish,nu}` | Generic aliases (no tool dependency) |
| `colors.toml`     | `colors.zsh`                 | Catppuccin palette + LS_COLORS       |
| `icons.toml`      | `icons.zsh`                  | 100+ Nerd Font icons                 |
| `highlights.toml` | `highlights.zsh`             | Syntax highlighting rules            |

Tool-specific aliases live in `config/tools.d/TOOL.zsh` — loaded **only if the
tool is installed**.

```bash
# Regenerate all SSOT outputs
dot generate

# Regenerate specific target
dot generate aliases
```

---

## 🔧 dot CLI

Unified management interface — works in **every shell**.

```
dot                          # Help
dot info                     # System & dotfiles overview
dot status                   # Quick dashboard
dot doctor                   # Health check
dot shells                   # Shell status
dot tools                    # Tool availability report

dot theme [name]             # Switch Starship theme (interactive FZF)
dot theme list               # List themes
dot theme preview            # Preview all themes

dot generate [target]        # Generate SSOT files
dot link                     # Create symlinks
dot edit [file]              # Open in editor

dot ssh info                 # SSH config overview
dot ssh keys                 # List all SSH keys
dot ssh test [host]          # Test connectivity
dot ssh audit                # Security audit
dot ssh generate             # Generate new key
dot ssh backup               # Encrypted backup

dot git-sign info            # Signing configuration
dot git-sign ssh             # Configure SSH signing

dot secret list              # Manage secrets
dot backup                   # Snapshot dotfiles
dot benchmark [n]            # Startup benchmark
dot color                    # Color palette test
dot path                     # PATH audit
dot alias [search]           # Browse aliases
dot diff                     # Uncommitted changes

dot terminal                 # Terminal management
dot terminal info            # Current terminal info (auto-detected)
dot terminal info ghostty    # Specific terminal info
dot terminal update          # Update all terminal configs
dot terminal edit            # Edit current terminal config
dot terminal list            # Supported terminals

dot editor                   # Editor management
dot editor info              # Neovim info
dot editor info all          # All editors info
dot editor update            # Update editor config
dot editor health            # Neovim health check
dot editor reinstall         # Reinstall from repo
dot editor list              # Supported editors

dot nix                      # Nix management
dot nix info                 # Installation info
dot nix dev                  # Enter dev shell
dot nix install              # Install packages from flake
dot nix search <pkg>         # Search nixpkgs
dot nix clean                # Garbage collect
```

---

## 🎨 Starship Themes

Three context-aware themes, auto-selected based on environment:

| Theme         | Context              | Style                         |
| :------------ | :------------------- | :---------------------------- |
| **Powerline** | Workstation, desktop | Rounded segments, full info   |
| **Minimal**   | SSH, Docker, remote  | Clean two-line, low bandwidth |
| **Nerd**      | VPS, Proxmox, K8s    | Maximum info density          |

```bash
dot theme                    # Interactive FZF selector
dot theme minimal            # Direct switch
dot theme preview            # Preview all
```

Auto-detection priority:

1. `STARSHIP_THEME` env var (manual override)
2. Proxmox / Kubernetes / VPS → **Nerd**
3. SSH / Docker / Container → **Minimal**
4. Local workstation → **Powerline**

---

## 🛠️ Integrated Tools

> Each tool: `tools/TOOL.zsh` (code) + `config/tools.d/TOOL.zsh` (config).
> Loaded **only if installed**. Zero wasted aliases.

### Essential

| Tool                                             | Purpose             | Config                       |
| ------------------------------------------------ | ------------------- | ---------------------------- |
| [eza](https://eza.rocks)                         | Modern `ls`         | `config/tools.d/eza.zsh`     |
| [fzf](https://github.com/junegunn/fzf)           | Fuzzy finder        | `config/tools.d/fzf.zsh`     |
| [bat](https://github.com/sharkdp/bat)            | Syntax `cat`        | `config/tools.d/bat.zsh`     |
| [fd](https://github.com/sharkdp/fd)              | Modern `find`       | `config/tools.d/fd.zsh`      |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Ultra-fast `grep`   | `config/tools.d/ripgrep.zsh` |
| [zoxide](https://github.com/ajeetdsouza/zoxide)  | Smart `cd`          | `config/tools.d/zoxide.zsh`  |
| [starship](https://starship.rs)                  | Prompt (3 themes)   | `themes/starship-*.toml`     |
| [delta](https://github.com/dandavison/delta)     | Git diff            | `config/tools.d/delta.zsh`   |
| [atuin](https://atuin.sh)                        | Shell history       | `config/tools.d/atuin.zsh`   |
| [mise](https://mise.jdx.dev)                     | Runtime manager     | `config/tools.d/mise.zsh`    |
| [jq](https://jqlang.github.io/jq/)               | JSON processor      | `config/tools.d/jq.zsh`      |
| [yq](https://github.com/mikefarah/yq)            | YAML/TOML processor | `config/tools.d/yq.zsh`      |

### Editors & [Terminals](terminals.md)

| Tool                                       | Purpose  | Auto-Clone                                                                                |
| ------------------------------------------ | -------- | ----------------------------------------------------------------------------------------- |
| [Neovim](https://neovim.io)                | Editor   | [`nvim-enterprise`](https://github.com/ca971/nvim-enterprise) → `~/.config/nvim`          |
| [Ghostty](https://ghostty.org)             | Terminal | [`ghostty-config`](https://github.com/ca971/ghostty-config) → `~/.config/ghostty`         |
| [WezTerm](https://wezfurlong.org/wezterm/) | Terminal | [`wezterm-enterprise`](https://github.com/ca971/wezterm-enterprise) → `~/.config/wezterm` |
| [Kitty](https://sw.kovidgoyal.net/kitty/)  | Terminal | [`kitty`](https://github.com/ca971/kitty) → `~/.config/kitty`                             |
| [Alacritty](https://alacritty.org)         | Terminal | [`alacritty`](https://github.com/ca971/alacritty) → `~/.config/alacritty`                 |
| [iTerm2](https://iterm2.com)               | Terminal | Shell integration + features                                                              |

### DevOps

| Tool                                                             | Purpose              | Config                          |
| ---------------------------------------------------------------- | -------------------- | ------------------------------- |
| [docker](https://docker.com) / [podman](https://podman.io)       | Containers           | `config/tools.d/docker.zsh`     |
| [kubectl](https://kubernetes.io)                                 | Kubernetes           | `config/tools.d/kubernetes.zsh` |
| [helm](https://helm.sh)                                          | K8s packages         | `config/tools.d/helm.zsh`       |
| [k9s](https://k9scli.io)                                         | K8s TUI              | `config/tools.d/k9s.zsh`        |
| [terraform](https://terraform.io) / [tofu](https://opentofu.org) | IaC                  | `config/tools.d/terraform.zsh`  |
| [ansible](https://ansible.com)                                   | Config management    | `config/tools.d/ansible.zsh`    |
| [lazygit](https://github.com/jesseduffield/lazygit)              | Git TUI              | `config/tools.d/lazygit.zsh`    |
| [lazydocker](https://github.com/jesseduffield/lazydocker)        | Docker TUI           | `config/tools.d/lazygit.zsh`    |
| [dive](https://github.com/wagoodman/dive)                        | Docker layers        | `config/tools.d/dive.zsh`       |
| [act](https://github.com/nektos/act)                             | GitHub Actions local | `config/tools.d/act.zsh`        |
| [trivy](https://trivy.dev)                                       | Security scanner     | `config/tools.d/trivy.zsh`      |
| [sops](https://github.com/getsops/sops)                          | Secrets in Git       | `config/tools.d/sops.zsh`       |

### Utilities

| Tool                                                                            | Purpose                 | Config                          |
| ------------------------------------------------------------------------------- | ----------------------- | ------------------------------- |
| [btop](https://github.com/aristocratos/btop)                                    | System monitor          | `config/tools.d/btop.zsh`       |
| [dust](https://github.com/bootandy/dust) / [duf](https://github.com/muesli/duf) | Disk usage              | `config/tools.d/dust.zsh`       |
| [yazi](https://yazi-rs.github.io)                                               | File manager            | `config/tools.d/yazi.zsh`       |
| [navi](https://github.com/denisidoro/navi)                                      | Cheatsheets             | `config/tools.d/navi.zsh`       |
| [gum](https://github.com/charmbracelet/gum)                                     | TUI scripting           | `config/tools.d/gum.zsh`        |
| [age](https://github.com/FiloSottile/age)                                       | Encryption              | `config/tools.d/age.zsh`        |
| [hyperfine](https://github.com/sharkdp/hyperfine)                               | Benchmarks              | `config/tools.d/hyperfine.zsh`  |
| [tokei](https://github.com/XAMPPRocky/tokei)                                    | Code stats              | `config/tools.d/tokei.zsh`      |
| [procs](https://github.com/dalance/procs)                                       | Modern `ps`             | `config/tools.d/procs.zsh`      |
| [topgrade](https://github.com/topgrade-rs/topgrade)                             | Universal updater       | `config/topgrade/topgrade.toml` |
| [glow](https://github.com/charmbracelet/glow)                                   | Markdown renderer       | `config/tools.d/glow.zsh`       |
| [xh](https://github.com/ducaale/xh)                                             | HTTP client             | `config/tools.d/xh.zsh`         |
| [sd](https://github.com/chmln/sd)                                               | Modern `sed`            | `config/tools.d/sd.zsh`         |
| [ouch](https://github.com/ouch-org/ouch)                                        | Compression             | `config/tools.d/ouch.zsh`       |
| [difftastic](https://difftastic.wilfred.me.uk)                                  | Structural diff         | `config/tools.d/difftastic.zsh` |
| [broot](https://dystroy.org/broot/)                                             | Tree explorer           | `config/tools.d/broot.zsh`      |
| [viddy](https://github.com/sachaos/viddy)                                       | Modern `watch`          | `config/tools.d/viddy.zsh`      |
| [lnav](https://lnav.org)                                                        | Log navigator           | `config/tools.d/lnav.zsh`       |
| [curlie](https://github.com/rs/curlie)                                          | curl + httpie           | `config/tools.d/curlie.zsh`     |
| [bandwhich](https://github.com/imsnif/bandwhich)                                | Bandwidth monitor       | `config/tools.d/bandwhich.zsh`  |
| [tmux](https://github.com/tmux/tmux)                                            | Multiplexer             | `config/tools.d/tmux.zsh`       |
| [zellij](https://zellij.dev)                                                    | Modern multiplexer      | `config/tools.d/zellij.zsh`     |
| [gh](https://cli.github.com)                                                    | GitHub CLI              | `config/tools.d/gh.zsh`         |
| [tldr](https://tldr.sh)                                                         | Man pages simplified    | `config/tools.d/tldr.zsh`       |
| [thefuck](https://github.com/nvbn/thefuck)                                      | Command correction      | `config/tools.d/thefuck.zsh`    |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch)                         | System info             | `config/tools.d/fastfetch.zsh`  |
| [just](https://just.systems)                                                    | Task runner             | `config/tools.d/just.zsh`       |
| [chezmoi](https://chezmoi.io)                                                   | Dotfile manager         | `config/tools.d/chezmoi.zsh`    |
| [direnv](https://direnv.net)                                                    | Dir environments        | `config/tools.d/direnv.zsh`     |
| [carapace](https://carapace.sh)                                                 | Multi-shell completions | `config/tools.d/carapace.zsh`   |

### Package Management

| Tool                         | Purpose                                              |
| ---------------------------- | ---------------------------------------------------- |
| [Nix](https://nixos.org)     | Declarative package manager — `config/nix/flake.nix` |
| [Homebrew](https://brew.sh)  | macOS package manager                                |
| [mise](https://mise.jdx.dev) | Runtime version manager                              |

---

## 🔐 Security

### SSH

| Feature                                 | Status |
| :-------------------------------------- | :----- |
| Modular config (`config.d/`)            | ✅     |
| Dynamic key discovery (`id_*`)          | ✅     |
| Hardened algorithms (ed25519, chacha20) | ✅     |
| macOS Keychain integration              | ✅     |
| Agent forwarding disabled               | ✅     |
| Connection multiplexing                 | ✅     |
| Encrypted key backup (age/GPG)          | ✅     |
| Key age monitoring + rotation           | ✅     |
| Security audit (`ssh-audit`)            | ✅     |
| Auto-permissions (600/700)              | ✅     |

### GPG

| Feature                      | Status |
| :--------------------------- | :----- |
| Auto-symlink configs         | ✅     |
| Agent auto-start             | ✅     |
| Pinentry auto-detect         | ✅     |
| Key management functions     | ✅     |
| Security audit (`gpg-audit`) | ✅     |

### Git

| Feature                             | Status |
| :---------------------------------- | :----- |
| SSH commit signing                  | ✅     |
| Allowed signers management          | ✅     |
| Credential helpers (platform-aware) | ✅     |
| Secrets pre-commit scanner          | ✅     |
| History secrets filtering           | ✅     |

---

## 🔑 SSH Management

```bash
ssh-keys                    # List all keys with fingerprints
ssh-key-generate            # Generate new key (ed25519, KDF 200)
ssh-key-copy                # Copy public key to clipboard
ssh-key-delete              # Delete key pair (FZF)

ssh-config-info             # Config overview
ssh-config-edit work        # Edit work servers
ssh-config-add personal     # Add host interactively
ssh-config-test             # Test all connections

ssh-audit                   # Full security audit
ssh-backup                  # Encrypted backup (age/GPG)
ssh-restore                 # Restore from backup
ssh-key-age                 # Key age report
```

---

## 📝 [Git](git.md) Integration

```bash
# Workflow
gconv                       # Conventional commit (interactive FZF)
gbranch                     # Create named branch (type/ticket-desc)
gflow                       # PR workflow menu
gpr                         # Create pull request
greview                     # Review PRs (FZF)

# Analysis
ginfo                       # Repository info
grepo                       # Repository health
gstandup                    # Yesterday's work
gchangelog                  # Auto-changelog from commits
gstats                      # File change statistics

# Release
grelease                    # Tag + push + GitHub release

# Signing
git-signing-ssh             # Configure SSH signing
git-signing-info            # Show signing config
git-verify                  # Verify commit signature

# Templates
git-templates-install       # Install git-templates hooks
git-templates-info          # Show hook status
```

---

## ❄️ Nix — Declarative Environment

Reproducible cross-platform environment via Nix Flakes. Same 60+ tools on macOS
and Linux with a single command.

```bash
# Enter dev shell (temporary, all tools available)
cd ~/dotfiles/config/nix
nix develop

# Install permanently to your profile
nix profile install .

# Update all inputs
nix flake update

# Via dot CLI
dot nix info              # Nix installation info
dot nix dev               # Enter dev shell
dot nix install           # Install all packages
dot nix update            # Update flake inputs
dot nix rebuild           # Update + reinstall
dot nix search ripgrep    # Search packages
dot nix list              # Installed packages
dot nix clean             # Garbage collect
dot nix shell python      # Language-specific dev shell
dot nix audit             # Security audit
```

### Flake Structure

```
config/nix/
├── flake.nix              # Entry point — cross-platform outputs
├── flake.lock             # Pinned versions (auto-generated)
├── home.nix               # Home Manager (optional)
├── packages/
│   ├── common.nix         # 60+ packages for ALL platforms
│   ├── darwin.nix         # macOS-specific (GNU coreutils, etc.)
│   └── linux.nix          # Linux-specific (iproute2, xclip, etc.)
└── shells/
    └── default.nix        # Dev shell configuration
```

### New Machine Setup

```bash
# 1. Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh

# 2. Clone dotfiles
git clone git@github.com:ca971/dotfiles.git ~/dotfiles

# 3. Install everything
cd ~/dotfiles/config/nix && nix profile install .

# 4. Bootstrap dotfiles
sh ~/dotfiles/bootstrap.sh
```

### Nix usage

```bash
# Dev shell
cd ~/dotfiles/config/nix
nix flake update                        # Regenerate
nix flake show .                        # Test
nix develop                             # Default shell
nix develop .#devShells.aarch64-darwin  # Explicit system

# Install environment
nix profile install .                   # All packages
nix profile list                        # List installed
nix profile upgrade '.*'                # Update all
nix-install-env                         # Install complete environment

# Search
nix search nixpkgs ripgrep              # Search packages

# Garbage collect
nix-collect-garbage -d                  # Remove old generations
```

---

## 🖥️ Terminal & Editor Management

All terminal and editor configs are **auto-cloned** from GitHub repos on first
launch and **auto-updated** in background on subsequent launches.

### Terminal Management

```bash
dot terminal                  # Help
dot terminal info             # Auto-detect current terminal
dot terminal info ghostty     # Specific terminal info
dot terminal update           # Update ALL terminal configs
dot terminal update kitty     # Update specific terminal
dot terminal edit             # Edit current terminal config
dot terminal reinstall kitty  # Reinstall from repo
dot terminal list             # Supported terminals
```

| Terminal  | Config Repo                                                               | Auto-Clone |
| :-------- | :------------------------------------------------------------------------ | :--------: |
| Ghostty   | [`ca971/ghostty-config`](https://github.com/ca971/ghostty-config)         |     ✅     |
| WezTerm   | [`ca971/wezterm-enterprise`](https://github.com/ca971/wezterm-enterprise) |     ✅     |
| Kitty     | [`ca971/kitty`](https://github.com/ca971/kitty)                           |     ✅     |
| Alacritty | [`ca971/alacritty`](https://github.com/ca971/alacritty)                   |     ✅     |
| iTerm2    | Shell integration + features                                              |    N/A     |

### Editor Management

```bash
dot editor                    # Help
dot editor info               # Neovim info
dot editor info all           # All editors
dot editor update             # Update nvim-enterprise
dot editor health             # Neovim checkhealth
dot editor reinstall neovim   # Reinstall from repo
dot editor list               # Supported editors
```

| Editor | Config Repo                                                         | Auto-Clone |
| :----- | :------------------------------------------------------------------ | :--------: |
| Neovim | [`ca971/nvim-enterprise`](https://github.com/ca971/nvim-enterprise) |     ✅     |
| Helix  | Local config                                                        |     ❌     |
| Vim    | Local config                                                        |     ❌     |

---

## ⚡ Performance

Target: **< 500ms** startup (with fastfetch).

```bash
dot benchmark 10            # 10-iteration benchmark
dot profile                 # ZSH zprof output
```

| Optimization | Technique                          |
| :----------- | :--------------------------------- |
| Turbo mode   | Zinit `wait"N"` async loading      |
| Lazy loading | Tool shims, deferred init          |
| Compilation  | `.zwc` bytecode (background)       |
| Conditional  | `(( $+commands[tool] ))` — no fork |
| Caching      | Completions cached 24h             |
| Background   | SSH perms, git-templates in `&!`   |

---

## 🧪 Testing

```bash
just test                   # Run all test suites
dot doctor                  # Health check (60+ checks)

# Individual suites
zsh tests/test-aliases.zsh
zsh tests/test-functions.zsh
zsh tests/test-platform.zsh
```

---

## 🤝 Contributing

```bash
git checkout -b feat/amazing-feature
gconv                       # Interactive conventional commit
git push origin feat/amazing-feature
gpr                         # Create PR
```

| Contribution   | How                                                                    |
| :------------- | :--------------------------------------------------------------------- |
| Add a tool     | Create `tools/TOOL.zsh` + `config/tools.d/TOOL.zsh`                    |
| Add an alias   | Edit `config/tools.d/TOOL.zsh` (tool) or `ssot/aliases.toml` (generic) |
| Add a platform | Create `platform/DISTRO.zsh`                                           |
| Fix an issue   | Fork → branch → commit → PR                                            |

---

## 📄 License

[MIT](./LICENSE) — free for personal, educational, and commercial use.

---

<div align="center">

**Crafted with ❤️ by [ca971](https://github.com/ca971) — for power users who
live in the terminal.**

[⬆ Back to Top](#-dotfiles-enterprise)

[![Stars](https://img.shields.io/github/stars/ca971/dotfiles?style=social)](https://github.com/ca971/dotfiles)
[![Issues](https://img.shields.io/github/issues/ca971/dotfiles?style=social)](https://github.com/ca971/dotfiles/issues)
[![Forks](https://img.shields.io/github/forks/ca971/dotfiles?style=social)](https://github.com/ca971/dotfiles/fork)

</div>
