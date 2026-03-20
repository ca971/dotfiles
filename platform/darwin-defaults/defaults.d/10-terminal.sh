#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/10-terminal.sh
# @description Terminal.app, default shell, iTerm2 preferences.
# ============================================================================

# ── Terminal.app ─────────────────────────────────────────────────────────────

# UTF-8 only
dw com.apple.terminal StringEncodings -array 4

# Secure Keyboard Entry
dw com.apple.terminal SecureKeyboardEntry bool true

# Disable line marks
dw com.apple.Terminal ShowLineMarks int 0

# ── Default Shell ────────────────────────────────────────────────────────────

if ! $_MACOS_DRY_RUN; then
    current_shell="$(dscl . -read "/Users/$(whoami)" UserShell | awk '{print $2}')"
    zsh_path="$(command -v zsh 2> /dev/null || echo "/bin/zsh")"

    if [[ "$current_shell" != "$zsh_path" ]]; then
        # Ensure zsh is in /etc/shells
        if ! grep -qF "$zsh_path" /etc/shells 2> /dev/null; then
            echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
        fi
        chsh -s "$zsh_path" 2> /dev/null || true
        _ok "Default shell changed to ${zsh_path}"
    else
        _ok "Default shell already set to ${zsh_path}"
    fi
fi

# ── iTerm2 ───────────────────────────────────────────────────────────────────

# Don't prompt on quit
dw com.googlecode.iterm2 PromptOnQuit bool false

# Load preferences from dotfiles
dw com.googlecode.iterm2 PrefsCustomFolder string "${DOTFILES_DIR}/config/iterm2"
dw com.googlecode.iterm2 LoadPrefsFromCustomFolder bool true
