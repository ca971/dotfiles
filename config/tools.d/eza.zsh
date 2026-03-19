# ============================================================================
# Eza — aliases & options
# @see https://eza.rocks
# ============================================================================

_e='eza --icons=auto --group-directories-first --color=auto'

# -- BROWSING -----------------------------------------------------------------
# Quick look
alias l="$_e"
# Daily workhorse
alias ll="$_e -l --git --header --time-style=relative"
# Debug configs
alias la="$_e -la --git --header --time-style=relative"
# Folders with 100+ files
alias lw="$_e --across"

# -- STRUCTURE ----------------------------------------------------------------
# Project overview
alias lt="$_e --tree --level=1 --git-ignore"
# Drill down
alias lt2="$_e --tree --level=2 --git-ignore"
# Deep monorepo scan
alias lt3="$_e --tree --level=3 --git-ignore"
# Visual disk audit
alias lts="$_e --tree --level=2 --git-ignore -l --total-size --no-permissions --no-user --no-time"

# -- FOCUS --------------------------------------------------------------------
# Navigate project roots
alias ld="eza --icons=auto --color=auto -lD"
# Skip dir noise
alias lf="eza --icons=auto --color=auto -lf --git --header --time-style=relative"
# Audit .env, .gitignore
alias 'l.'="eza --icons=auto --color=auto -la --git --header --time-style=relative -d .*"
# Debug chezmoi/stow/brew
alias lnk="eza --icons=auto --color=auto -la --header --time-style=relative | rg '\->'"

# -- ANALYSIS -----------------------------------------------------------------
# "What just changed?"
alias lm="$_e -l --sort=modified --reverse --git --time-style=relative"
# "What's new here?"
alias lc="$_e -l --sort=created --reverse --git --time-style=relative"
# "What's eating disk?"
alias lS="$_e -l --sort=size --reverse --total-size"
# Group file types
alias lx="$_e -l --sort=extension --git --header"

# -- SCRIPTING ----------------------------------------------------------------
# Pipe to fzf/xargs/wc
alias l1="eza --icons=never --group-directories-first --color=never -1"
# Scan nested dirs flat
alias lr="eza --icons=auto --color=auto -l --recurse --git --time-style=relative --git-ignore"

# macOS
# Debug Gatekeeper/xattr
alias 'lx@'="eza --icons=auto --color=auto -la@ --header"

export EZA_COLORS="reset"
export EZA_ICON_SPACING=2
