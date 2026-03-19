#!/usr/bin/env bash
cmd_generate() {
    local target="${1:-all}"
    _banner
    _section "${I_SETTINGS}  SSOT Generation"
    case "$target" in
        all) bash "${DOTFILES_DIR}/ssot/generators/generate-all.sh" ;;
        aliases) bash "${DOTFILES_DIR}/ssot/generators/generate-aliases.sh" ;;
        colors) bash "${DOTFILES_DIR}/ssot/generators/generate-colors.sh" ;;
        icons) bash "${DOTFILES_DIR}/ssot/generators/generate-icons.sh" ;;
        highlights) bash "${DOTFILES_DIR}/ssot/generators/generate-highlights.sh" ;;
        *) _err "Unknown: $target" ;;
    esac
}
