#!/bin/sh
# ============================================================================
# @file        shells/shared/tools-init.sh
# @description Tool initialization dispatcher. Outputs shell-specific eval
#              code for all tools that need init (starship, zoxide, etc.).
#
# @usage       eval "$(sh shells/shared/tools-init.sh bash)"
#              In fish: sh shells/shared/tools-init.sh fish | source
#
# @version     1.0.0
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

# ── Atuin ────────────────────────────────────────────────────────────────────
_has atuin && atuin init "$SHELL_NAME" --disable-up-arrow 2> /dev/null

# ── Mise ─────────────────────────────────────────────────────────────────────
_has mise && mise activate "$SHELL_NAME" 2> /dev/null

# ── Direnv ───────────────────────────────────────────────────────────────────
_has direnv && direnv hook "$SHELL_NAME" 2> /dev/null

# ── FZF ──────────────────────────────────────────────────────────────────────
if _has fzf; then
    case "$SHELL_NAME" in
        zsh) fzf --zsh 2> /dev/null ;;
        bash) fzf --bash 2> /dev/null ;;
        fish) fzf --fish 2> /dev/null ;;
    esac
fi

# ── Carapace ─────────────────────────────────────────────────────────────────
_has carapace && carapace _carapace "$SHELL_NAME" 2> /dev/null

# ── Navi ─────────────────────────────────────────────────────────────────────
_has navi && navi widget "$SHELL_NAME" 2> /dev/null
