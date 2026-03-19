# ============================================================================
# Kitty — aliases & options
# @see https://sw.kovidgoyal.net/kitty/
# ============================================================================

alias icat="kitten icat"
alias kssh="kitten ssh"
alias kdiff="kitten diff"
alias kunicode="kitten unicode_input"
alias kclip="kitten clipboard"
alias kt-tab="kitty @ launch --type=tab"
alias kt-split="kitty @ launch --type=window"
alias kt-ls="kitty @ ls"

export KITTY_LISTEN_ON="unix:/tmp/kitty-${USER}-$$"
export COLORTERM="truecolor"
