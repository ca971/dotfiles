#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/11-accessibility.sh
# @description Accessibility: motion, cursor, zoom, transparency.
# ============================================================================

# ── Motion ───────────────────────────────────────────────────────────────────

# Keep animations (set true to reduce)
dw com.apple.universalaccess reduceMotion bool false

# Keep transparency (set true to reduce)
dw com.apple.universalaccess reduceTransparency bool false

# ── Cursor ───────────────────────────────────────────────────────────────────

# Slightly larger cursor (1.0=default, 4.0=max)
dw com.apple.universalaccess mouseDriverCursorSize float 1.5

# Shake to locate cursor
dw NSGlobalDomain CGDisableCursorLocationMagnification bool false

# ── Zoom ─────────────────────────────────────────────────────────────────────

if ! $_MACOS_DRY_RUN; then
    # Ctrl + scroll wheel to zoom
    sudo defaults write com.apple.universalaccess \
        closeViewScrollWheelToggle -bool true 2> /dev/null || true
    sudo defaults write com.apple.universalaccess \
        HIDScrollZoomModifierMask -int 262144 2> /dev/null || true

    # Follow keyboard focus while zoomed
    sudo defaults write com.apple.universalaccess \
        closeViewZoomFollowsFocus -bool true 2> /dev/null || true
fi
