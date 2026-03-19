# ============================================================================
# @file        Justfile
# @description Task automation for dotfiles management.
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     3.0.0
#
# @changelog   3.0.0 — Updated paths for config/ directory structure.
#              git/ → config/git/, ssh/ → config/ssh/
# ============================================================================

default:
  @just --list --unsorted

dotfiles_dir := env("DOTFILES_DIR", env("HOME") / "dotfiles")
zsh_dir := dotfiles_dir / "shells" / "zsh"

# ============================================================================
# Bootstrap & Setup
# ============================================================================

# Universal bootstrap (works with any shell)
bootstrap:
  @sh "{{dotfiles_dir}}/bootstrap.sh"

# Full setup: bootstrap + link + generate + permissions
setup:
  @just bootstrap
  @just link
  @just generate-all
  @just fix-perms
  @echo "✅ Setup complete — restart: exec \$$SHELL"

# Run the interactive installer
install:
  bash "{{dotfiles_dir}}/scripts/install.sh"

# ============================================================================
# Symlinks
# ============================================================================

# Create all required symlinks
link:
  #!/usr/bin/env bash
  set -uo pipefail
  echo "🔗 Creating symlinks..."

  DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"

  _link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    echo "  ✓ $(echo "$dst" | sed "s|${HOME}|~|") → $(echo "$src" | sed "s|${DOTFILES_DIR}/||")"
  }

  # ── ZSH ──
  [ -f "${DOTFILES_DIR}/shells/zsh/.zshenv" ] && \
    _link "${DOTFILES_DIR}/shells/zsh/.zshenv" "${HOME}/.zshenv"

  # ── Bash ──
  [ -f "${DOTFILES_DIR}/shells/bash/.bashrc" ] && \
    _link "${DOTFILES_DIR}/shells/bash/.bashrc" "${HOME}/.bashrc"
  [ -f "${DOTFILES_DIR}/shells/bash/.bash_profile" ] && \
    _link "${DOTFILES_DIR}/shells/bash/.bash_profile" "${HOME}/.bash_profile"

  # ── Fish ──
  [ -f "${DOTFILES_DIR}/shells/fish/config.fish" ] && \
    _link "${DOTFILES_DIR}/shells/fish/config.fish" "${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish"

  # ── Nushell ──
  [ -f "${DOTFILES_DIR}/shells/nushell/env.nu" ] && \
    _link "${DOTFILES_DIR}/shells/nushell/env.nu" "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/env.nu"
  [ -f "${DOTFILES_DIR}/shells/nushell/config.nu" ] && \
    _link "${DOTFILES_DIR}/shells/nushell/config.nu" "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/config.nu"

  # ── Nushell tool inits ──
  if command -v nu >/dev/null 2>&1; then
    NU_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/nushell"
    mkdir -p "$NU_CONFIG_DIR"
    echo "  ⚙ Pre-generating Nushell tool inits..."
    command -v zoxide >/dev/null 2>&1 && zoxide init nushell --cmd cd > "${NU_CONFIG_DIR}/zoxide.nu" 2>/dev/null || touch "${NU_CONFIG_DIR}/zoxide.nu"
    command -v atuin >/dev/null 2>&1 && atuin init nu --disable-up-arrow > "${NU_CONFIG_DIR}/atuin.nu" 2>/dev/null || touch "${NU_CONFIG_DIR}/atuin.nu"
    command -v carapace >/dev/null 2>&1 && carapace _carapace nushell > "${NU_CONFIG_DIR}/carapace.nu" 2>/dev/null || touch "${NU_CONFIG_DIR}/carapace.nu"
    echo "  ✓ Nushell tool inits generated"
  fi

  # ── Git config ──
  [ -f "${DOTFILES_DIR}/config/git/.gitconfig" ] && \
    _link "${DOTFILES_DIR}/config/git/.gitconfig" "${HOME}/.gitconfig"

  echo "✅ All symlinks created"

# Remove all dotfiles symlinks
unlink:
  #!/usr/bin/env bash
  echo "🔗 Removing symlinks..."
  for target in \
    "${HOME}/.zshenv" \
    "${HOME}/.bashrc" \
    "${HOME}/.bash_profile" \
    "${HOME}/.gitconfig" \
    "${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish" \
    "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/config.nu" \
    "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/env.nu"; do
    if [ -L "$target" ]; then
      rm -f "$target"
      echo "  ✗ $(echo "$target" | sed "s|${HOME}|~|")"
    fi
  done
  echo "✅ All symlinks removed"

# ============================================================================
# SSOT Generation
# ============================================================================

generate-all:
  @echo "🔄 Generating all SSOT outputs..."
  bash "{{dotfiles_dir}}/ssot/generators/generate-all.sh"

generate-aliases:
  bash "{{dotfiles_dir}}/ssot/generators/generate-aliases.sh"

generate-colors:
  bash "{{dotfiles_dir}}/ssot/generators/generate-colors.sh"

generate-icons:
  bash "{{dotfiles_dir}}/ssot/generators/generate-icons.sh"

generate-highlights:
  bash "{{dotfiles_dir}}/ssot/generators/generate-highlights.sh"

# ============================================================================
# Diagnostics & Health
# ============================================================================

doctor:
  bash "{{dotfiles_dir}}/scripts/doctor.sh"

tools:
  @zsh -ic 'tool_doctor'

platform:
  @zsh -ic 'platform_summary'

# Show configured shells status
shells:
  #!/usr/bin/env bash
  echo ""
  echo "  🐚 Shell Status"
  echo "  ═══════════════════════════════════"
  echo ""
  printf "  %-12s %-10s %-10s %s\n" "SHELL" "INSTALLED" "LINKED" "CONFIG"
  printf "  %-12s %-10s %-10s %s\n" "────────────" "──────────" "──────────" "──────────────"
  zsh_inst=$(command -v zsh >/dev/null 2>&1 && echo "✅" || echo "❌")
  zsh_link=$([ -L "${HOME}/.zshenv" ] && echo "✅" || echo "❌")
  printf "  %-12s %-10s %-10s %s\n" "zsh" "$zsh_inst" "$zsh_link" "shells/zsh/"
  bash_inst=$(command -v bash >/dev/null 2>&1 && echo "✅" || echo "❌")
  bash_link=$([ -L "${HOME}/.bashrc" ] && echo "✅" || echo "❌")
  printf "  %-12s %-10s %-10s %s\n" "bash" "$bash_inst" "$bash_link" "shells/bash/"
  fish_inst=$(command -v fish >/dev/null 2>&1 && echo "✅" || echo "❌")
  fish_link=$([ -L "${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish" ] && echo "✅" || echo "❌")
  printf "  %-12s %-10s %-10s %s\n" "fish" "$fish_inst" "$fish_link" "shells/fish/"
  nu_inst=$(command -v nu >/dev/null 2>&1 && echo "✅" || echo "❌")
  nu_link=$([ -L "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/config.nu" ] && echo "✅" || echo "❌")
  printf "  %-12s %-10s %-10s %s\n" "nushell" "$nu_inst" "$nu_link" "shells/nushell/"
  echo ""
  echo "  Default: $(basename "${SHELL:-unknown}")"
  echo ""

# Find duplicate alias definitions
duplicates:
  @zsh "{{dotfiles_dir}}/scripts/find-duplicate-aliases.zsh"

# Auto-fix duplicate aliases
fix-duplicates:
  @zsh "{{dotfiles_dir}}/scripts/find-duplicate-aliases.zsh" --fix
  @just generate-all

# ============================================================================
# Performance
# ============================================================================

benchmark:
  @echo "⏱  Benchmarking ZSH startup time..."
  @for i in $$(seq 1 10); do /usr/bin/time zsh -ic exit 2>&1; done

profile:
  @ZSH_PROFILE=1 zsh -ic exit

benchmark-hyperfine:
  @command -v hyperfine >/dev/null 2>&1 && \
    hyperfine --warmup 3 --min-runs 10 'zsh -ic exit' || \
    echo "❌ hyperfine not installed"

benchmark-shells:
  #!/usr/bin/env bash
  echo "⏱  Shell Startup Comparison"
  echo ""
  for sh in zsh bash fish; do
    if command -v "$sh" >/dev/null 2>&1; then
      printf "  %-8s " "$sh"
      /usr/bin/time "$sh" -ic exit 2>&1 | grep real || echo ""
    fi
  done
  echo ""

# ============================================================================
# Maintenance
# ============================================================================

update:
  @echo "🔄 Updating dotfiles..."
  cd "{{dotfiles_dir}}" && git pull --rebase --autostash
  @just generate-all

upgrade:
  @just update
  @zsh -ic 'for f in {{dotfiles_dir}}/**/*.zsh(N); do zcompile "$$f" 2>/dev/null; done' || true
  @echo "✅ Upgrade complete"

clean:
  @echo "🧹 Cleaning..."
  find "{{dotfiles_dir}}" -name "*.zwc" -delete 2>/dev/null || true
  find "{{dotfiles_dir}}" -name "*.zwc.old" -delete 2>/dev/null || true
  rm -rf "{{dotfiles_dir}}/cache/"* 2>/dev/null || true
  @echo "✅ Clean complete"

reset-generated:
  rm -f "{{dotfiles_dir}}/generated/"*.zsh 2>/dev/null || true
  rm -f "{{dotfiles_dir}}/generated/"*.fish 2>/dev/null || true
  rm -f "{{dotfiles_dir}}/generated/"*.nu 2>/dev/null || true
  rm -f "{{dotfiles_dir}}/generated/"*.bash 2>/dev/null || true
  @just generate-all

# Make bin/ scripts executable
fix-perms:
  @chmod +x "{{dotfiles_dir}}/bin/"* 2>/dev/null || true
  @chmod +x "{{dotfiles_dir}}/ssot/generators/"*.sh 2>/dev/null || true
  @echo "✅ Permissions fixed"

# ============================================================================
# Development & Testing
# ============================================================================

test:
  @echo "🧪 Running tests..."
  @for f in "{{dotfiles_dir}}"/tests/*.zsh; do echo "  Testing: $$(basename $$f)"; zsh "$$f"; done

lint:
  @echo "🔍 Linting..."
  @find "{{dotfiles_dir}}" -name "*.sh" -exec shellcheck {} + 2>/dev/null || true

edit:
  @$${EDITOR:-nvim} "{{dotfiles_dir}}"

tree:
  @command -v eza >/dev/null 2>&1 && \
    eza --tree --icons --git-ignore -I '.git|cache|*.zwc|*.zwc.old|git-templates' "{{dotfiles_dir}}" || \
    find "{{dotfiles_dir}}" -not -path '*/\.*' -not -name '*.zwc' | sort | head -120

# Show dotfiles info
info:
  #!/usr/bin/env bash
  echo ""
  echo "  📦 Dotfiles Info"
  echo "  ═══════════════════════════════════"
  echo "  Root:      {{dotfiles_dir}}"
  echo "  ZSH:       {{zsh_dir}}"
  echo "  Git:       $(cd {{dotfiles_dir}} && git rev-parse --short HEAD 2>/dev/null || echo 'N/A') ($(cd {{dotfiles_dir}} && git branch --show-current 2>/dev/null || echo 'N/A'))"
  echo "  Version:   $(grep ZSH_CONFIG_VERSION {{zsh_dir}}/.zshenv 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo 'N/A')"
  echo "  Shell:     ${SHELL:-unknown}"
  echo "  Platform:  $(uname -s) ($(uname -m))"
  echo "  ═══════════════════════════════════"
  echo ""
