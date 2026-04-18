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

# ── Mise ─────────────────────────────────────────────────────────────────────
_has mise && mise activate "$SHELL_NAME" 2> /dev/null

# ── Direnv ───────────────────────────────────────────────────────────────────
_has direnv && direnv hook "$SHELL_NAME" 2> /dev/null

# ── FZF ──────────────────────────────────────────────────────────────────────
if _has fzf; then
    _fzf_ctrl_r_flag=""
    if _has atuin; then
        _fzf_ctrl_r_flag="--no-ctrl-r"
    fi

    case "$SHELL_NAME" in
        zsh) fzf --zsh $_fzf_ctrl_r_flag 2> /dev/null ;;
        bash) fzf --bash $_fzf_ctrl_r_flag 2> /dev/null ;;
        fish) fzf --fish $_fzf_ctrl_r_flag 2> /dev/null ;;
    esac

    # Flag to prevent tools/fzf.zsh from re-initializing and overwriting bindings
    echo "export _FZF_INITIALIZED=1"
    unset _fzf_ctrl_r_flag
fi

# ── Atuin (after fzf → his Ctrl+R wins) ──────────────────────────────────────
if _has atuin; then
    atuin init "$SHELL_NAME" --disable-up-arrow 2> /dev/null
    # Flag to prevent tools/atuin.zsh from re-initializing
    echo "export _ATUIN_INITIALIZED=1"
fi

# ── Carapace ─────────────────────────────────────────────────────────────────
_has carapace && carapace _carapace "$SHELL_NAME" 2> /dev/null

# ── Navi ─────────────────────────────────────────────────────────────────────
_has navi && navi widget "$SHELL_NAME" 2> /dev/null
