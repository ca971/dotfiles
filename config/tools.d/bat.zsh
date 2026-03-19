# ============================================================================
# Bat — aliases & options
# @see https://github.com/sharkdp/bat
# ============================================================================

alias cat="bat --style=auto"
alias catn="bat --style=numbers"
alias catp="bat --plain"
alias catd="bat --diff"
alias catj="bat --language=json"
alias caty="bat --language=yaml"
alias catm="bat --language=markdown"

export BAT_THEME="${BAT_THEME:-Catppuccin Mocha}"
export BAT_STYLE="${BAT_STYLE:-auto}"
export BAT_PAGER="${BAT_PAGER:-less -RFX}"
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/bat/config"
