#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/06-screen.sh
# @description Screenshots, Display, Screen Saver, Font Smoothing, HiDPI.
# ============================================================================

# ── Screenshots ──────────────────────────────────────────────────────────────

# Screenshot location
dw com.apple.screencapture location string "${HOME}/Screenshots"

# Create screenshots directory
if ! $_MACOS_DRY_RUN; then
    mkdir -p "${HOME}/Screenshots"
fi

# Format: png | jpg | gif | pdf | bmp | tiff
dw com.apple.screencapture type string "png"

# Disable shadow in screenshots
dw com.apple.screencapture disable-shadow bool true

# Include date in filename
dw com.apple.screencapture include-date bool true

# ── Screen Saver ─────────────────────────────────────────────────────────────

# Require password immediately after sleep/screen saver
dw com.apple.screensaver askForPassword int 1
dw com.apple.screensaver askForPasswordDelay int 0

# ── Display ──────────────────────────────────────────────────────────────────

# Subpixel font rendering: 0=off, 1=light, 2=medium, 3=strong
dw NSGlobalDomain AppleFontSmoothing int 1

# Enable HiDPI display modes (requires restart)
if ! $_MACOS_DRY_RUN; then
    sudo defaults write /Library/Preferences/com.apple.windowserver \
        DisplayResolutionEnabled -bool true 2> /dev/null || true
fi
