#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/07-security.sh
# @description Firewall, Gatekeeper, FileVault, Privacy, Updates.
# ============================================================================

# ── Firewall ─────────────────────────────────────────────────────────────────

if ! $_MACOS_DRY_RUN; then
    # Enable firewall
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on 2> /dev/null || true

    # Enable stealth mode (don't respond to ping)
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2> /dev/null || true
fi

# ── FileVault ────────────────────────────────────────────────────────────────

if ! $_MACOS_DRY_RUN; then
    if command -v fdesetup &> /dev/null; then
        if fdesetup status | grep -q "On"; then
            _ok "FileVault: already enabled"
        else
            _warn "FileVault is OFF — enable in System Settings > Privacy & Security"
        fi
    fi
fi

# ── Gatekeeper ───────────────────────────────────────────────────────────────

if ! $_MACOS_DRY_RUN; then
    sudo spctl --master-enable 2> /dev/null || true
fi

# ── Privacy ──────────────────────────────────────────────────────────────────

# Disable Siri
dw com.apple.assistant.support "Assistant Enabled" bool false

# Disable personalized ads
dw com.apple.AdLib allowApplePersonalizedAdvertising bool false
dw com.apple.AdLib allowIdentifierForAdvertising bool false

# ── Login ────────────────────────────────────────────────────────────────────

if ! $_MACOS_DRY_RUN; then
    # Show login window as name and password fields
    sudo defaults write /Library/Preferences/com.apple.loginwindow \
        SHOWFULLNAME -bool true 2> /dev/null || true

    # Disable guest account
    sudo defaults write /Library/Preferences/com.apple.loginwindow \
        GuestEnabled -bool false 2> /dev/null || true
fi

# ── Automatic Updates ────────────────────────────────────────────────────────

dw com.apple.SoftwareUpdate AutomaticCheckEnabled bool true
dw com.apple.SoftwareUpdate ScheduleFrequency int 1
dw com.apple.SoftwareUpdate AutomaticDownload bool true
dw com.apple.SoftwareUpdate CriticalUpdateInstall bool true
dw com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates bool true
dw com.apple.commerce AutoUpdate bool true
