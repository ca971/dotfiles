# ============================================================================
# Ripgrep — aliases & options
# @see https://github.com/BurntSushi/ripgrep
# ============================================================================

alias rgs="rg --smart-case --hidden --follow --glob '!.git' --glob '!node_modules'"
alias rgc="rg --smart-case --hidden --follow --glob '!.git' -C 3"
alias rgf="rg --smart-case --hidden --follow --glob '!.git' --files-with-matches"

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/config"
