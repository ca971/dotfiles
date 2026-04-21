#!/bin/sh
# ============================================================================
# @file        shells/shared/tools-init.sh
# @description Tool initialization dispatcher.
# @version     2.0.0
# ============================================================================

SHELL_NAME="${1:-bash}"
_has() { command -v "$1" > /dev/null 2>&1; }
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"

# ── Starship ─────────────────────────────────────────────────────────────────
if [ -z "${SKIP_STARSHIP:-}" ] && _has starship; then
    starship init "$SHELL_NAME" 2> /dev/null
fi

# ── Zoxide ───────────────────────────────────────────────────────────────────
_has zoxide && zoxide init "$SHELL_NAME" --cmd cd 2> /dev/null

# ── Mise ─────────────────────────────────────────────────────────────────────
_has mise && mise activate "$SHELL_NAME" 2> /dev/null

# ── Direnv ───────────────────────────────────────────────────────────────────
_has direnv && direnv hook "$SHELL_NAME" 2> /dev/null

# ── Carapace ─────────────────────────────────────────────────────────────────
_has carapace && carapace _carapace "$SHELL_NAME" 2> /dev/null

# ── Navi ─────────────────────────────────────────────────────────────────────
_has navi && navi widget "$SHELL_NAME" 2> /dev/null

# NOTE: fzf and atuin are intentionally omitted.
# They are handled by tools/fzf.zsh and tools/atuin.zsh (zsh)
# and by config.fish / .bashrc for other shells.
# Reason: the loading order and ZLE bindings must
# be precisely controlled on a per-shell basis.
