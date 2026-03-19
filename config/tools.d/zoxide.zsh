# ============================================================================
# Zoxide — options
# @see https://github.com/ajeetdsouza/zoxide
# ============================================================================

alias z="cd"

export _ZO_DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zoxide"
export _ZO_MAXAGE=10000
export _ZO_EXCLUDE_DIRS="/tmp/*:/var/tmp/*:${HOME}/.cache/*"
