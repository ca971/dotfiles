#!/usr/bin/env zsh
# ============================================================================
# @file        themes/starship-selector.zsh
# @description ZSH wrapper — sources the POSIX theme selector.
#              All starship-* commands are now in bin/ (cross-shell).
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-15
# @version     3.0.0
# ============================================================================

[[ -n "${_ZSH_STARSHIP_SELECTOR_LOADED:-}" ]] && return 0
readonly _ZSH_STARSHIP_SELECTOR_LOADED=1

# Source the POSIX selector (sets STARSHIP_CONFIG, adds bin/ to PATH)
if [[ -f "${DOTFILES_DIR}/themes/starship-selector.sh" ]]; then
  source "${DOTFILES_DIR}/themes/starship-selector.sh"
fi
