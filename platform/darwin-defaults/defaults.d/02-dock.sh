#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/02-dock.sh
# @description Dock, Dashboard, Mission Control, Hot Corners, Spaces.
# ============================================================================

# ── Dock Appearance ──────────────────────────────────────────────────────────

# Icon size (pixels)
dw com.apple.dock tilesize int 48

# Magnification
dw com.apple.dock magnification bool true
dw com.apple.dock largesize int 64

# Position: bottom | left | right
dw com.apple.dock orientation string "bottom"

# Minimize animation: genie | scale | suck
dw com.apple.dock mineffect string "scale"

# ── Dock Behavior ────────────────────────────────────────────────────────────

# Auto-hide
dw com.apple.dock autohide bool true

# Remove auto-hide delay
dw com.apple.dock autohide-delay float 0.0

# Faster auto-hide animation
dw com.apple.dock autohide-time-modifier float 0.3

# Show indicator lights for open apps
dw com.apple.dock show-process-indicators bool true

# Don't animate opening applications
dw com.apple.dock launchanim bool false

# Don't show recent applications
dw com.apple.dock show-recents bool false

# Minimize windows into application icon
dw com.apple.dock minimize-to-application bool true

# ── Mission Control ──────────────────────────────────────────────────────────

# Don't auto-rearrange Spaces based on most recent use
dw com.apple.dock mru-spaces bool false

# Group windows by application
dw com.apple.dock expose-group-apps bool true

# Faster Mission Control animation
dw com.apple.dock expose-animation-duration float 0.1

# ── Hot Corners ──────────────────────────────────────────────────────────────
#  0: No action            2: Mission Control      3: Application windows
#  4: Desktop              5: Start screen saver   6: Disable screen saver
#  7: Dashboard           10: Put display to sleep 11: Launchpad
# 12: Notification Center 13: Lock Screen          14: Quick Note

# Top-left: Mission Control
dw com.apple.dock wvous-tl-corner int 2
dw com.apple.dock wvous-tl-modifier int 0

# Top-right: Notification Center
dw com.apple.dock wvous-tr-corner int 12
dw com.apple.dock wvous-tr-modifier int 0

# Bottom-left: Lock Screen
dw com.apple.dock wvous-bl-corner int 13
dw com.apple.dock wvous-bl-modifier int 0

# Bottom-right: Desktop
dw com.apple.dock wvous-br-corner int 4
dw com.apple.dock wvous-br-modifier int 0

# ── Spaces ───────────────────────────────────────────────────────────────────

# Don't span displays for Spaces
dw com.apple.spaces spans-displays bool false
