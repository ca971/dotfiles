# ============================================================================
# @file        shells/fish/config.fish
# @description Fish configuration — sources shared resources + Fish-specific.
#              Only contains what is UNIQUE to Fish.
# @version     3.0.0
# ============================================================================

if not status is-interactive
    return
end

# ── Dotfiles ─────────────────────────────────────────────────────────────────
set -q DOTFILES_DIR; or set -gx DOTFILES_DIR "$HOME/dotfiles"

# ── Shared env (parse POSIX exports) ────────────────────────────────────────
if test -f "$DOTFILES_DIR/shells/shared/env.sh"
    for line in (grep '^export ' "$DOTFILES_DIR/shells/shared/env.sh" 2>/dev/null | sed 's/export //' | sed 's/#.*//' | sed 's/"//g' | grep '=')
        set -l key (string split -m1 '=' -- $line)[1]
        set -l val (string split -m1 '=' -- $line)[2]
        # Skip lines with shell substitutions we can't resolve
        string match -q '*\$*' -- "$val"; and continue
        string match -q '*:-*' -- "$val"; and continue
        test -n "$key" -a -n "$val"; and set -q $key; or set -gx $key $val
    end
end

# ── Fish-specific XDG ────────────────────────────────────────────────────────
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME "$HOME/.config"
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME "$HOME/.local/share"
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME "$HOME/.cache"

# ── PATH (Fish-native) ──────────────────────────────────────────────────────
fish_add_path --prepend "$HOME/.local/bin" "$HOME/bin" "$DOTFILES_DIR/bin"
test -x /opt/homebrew/bin/brew; and eval (/opt/homebrew/bin/brew shellenv)
test -d "$XDG_DATA_HOME/cargo/bin"; and fish_add_path --prepend "$XDG_DATA_HOME/cargo/bin"
test -d "$XDG_DATA_HOME/go/bin"; and fish_add_path --prepend "$XDG_DATA_HOME/go/bin"

# ── Starship theme ───────────────────────────────────────────────────────────
if set -q SSH_CONNECTION; or set -q SSH_CLIENT
    set -gx STARSHIP_CONFIG "$DOTFILES_DIR/themes/starship-minimal.toml"
else if test -d /etc/pve
    set -gx STARSHIP_CONFIG "$DOTFILES_DIR/themes/starship-nerd.toml"
else
    set -gx STARSHIP_CONFIG "$DOTFILES_DIR/themes/starship-powerline.toml"
end
set -gx STARSHIP_CACHE "$XDG_CACHE_HOME/starship"

# ── SSOT Aliases ─────────────────────────────────────────────────────────────
test -f "$DOTFILES_DIR/generated/aliases.fish"; and source "$DOTFILES_DIR/generated/aliases.fish"

# ── Tool inits (Fish-native — can't use shared dispatcher) ──────────────────
type -q starship; and starship init fish | source
type -q zoxide; and zoxide init fish --cmd cd | source
type -q atuin; and atuin init fish --disable-up-arrow | source
type -q mise; and mise activate fish | source
type -q direnv; and direnv hook fish | source
type -q fzf; and fzf --fish 2>/dev/null | source
type -q carapace; and carapace _carapace fish | source
type -q navi; and navi widget fish 2>/dev/null | source

# ── Yazi cd-on-exit (Fish-specific syntax) ───────────────────────────────────
if type -q yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        set cwd (cat -- "$tmp" 2>/dev/null)
        if test -n "$cwd" -a "$cwd" != "$PWD"
            cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end

# ── dot wrapper (Fish-specific syntax) ───────────────────────────────────────
function dot
    switch "$argv[1]"
        case theme th
            if test (count $argv) -ge 2
                switch $argv[2]
                    case powerline minimal nerd
                        set -gx STARSHIP_CONFIG "$DOTFILES_DIR/themes/starship-$argv[2].toml"
                        set -gx STARSHIP_THEME $argv[2]
                        echo "  ✓ Theme: $argv[2]"
                    case '*'
                        command dot theme $argv[2..]
                end
            else
                command dot theme
            end
        case cd
            cd "$DOTFILES_DIR"
        case '*'
            command dot $argv
    end
end

# ── Fish-specific ────────────────────────────────────────────────────────────
set -g fish_greeting ""

# ── Local ────────────────────────────────────────────────────────────────────
test -f "$DOTFILES_DIR/local/local.fish"; and source "$DOTFILES_DIR/local/local.fish"

# ── Fastfetch ────────────────────────────────────────────────────────────────
type -q fastfetch; and not set -q FISH_NO_FASTFETCH; and fastfetch

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/ca/.lmstudio/bin
# End of LM Studio CLI section

