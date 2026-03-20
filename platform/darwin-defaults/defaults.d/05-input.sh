#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/05-input.sh
# @description Keyboard, Trackpad, Mouse, Function Keys, Bluetooth.
# ============================================================================

# ── Keyboard ─────────────────────────────────────────────────────────────────

# Fast key repeat rate (lower = faster)
dw NSGlobalDomain KeyRepeat int 2

# Short delay until repeat (lower = shorter)
dw NSGlobalDomain InitialKeyRepeat int 15

# Full keyboard access for all UI controls (Tab everywhere)
dw NSGlobalDomain AppleKeyboardUIMode int 3

# Key repeat over press-and-hold
dw NSGlobalDomain ApplePressAndHoldEnabled bool false

# ── Function Keys ────────────────────────────────────────────────────────────

# Use F1, F2, etc. as standard function keys
dw NSGlobalDomain com.apple.keyboard.fnState bool true

# ── Trackpad ─────────────────────────────────────────────────────────────────

# Tap to click
dw com.apple.AppleMultitouchTrackpad Clicking bool true
dw com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking bool true

# Tap to click on login screen
if ! $_MACOS_DRY_RUN; then
    sudo defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true 2> /dev/null || true
fi

# Three-finger drag
dw com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag bool true
dw com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag bool true

# Tracking speed (0.0 to 3.0)
dw NSGlobalDomain com.apple.trackpad.scaling float 2.5

# Silent clicking
dw com.apple.AppleMultitouchTrackpad ActuationStrength int 0

# Secondary click (two-finger)
dw com.apple.AppleMultitouchTrackpad TrackpadRightClick bool true

# ── Mouse ────────────────────────────────────────────────────────────────────

# Tracking speed
dw NSGlobalDomain com.apple.mouse.scaling float 2.5

# ── Bluetooth Audio ──────────────────────────────────────────────────────────

# Increase Bluetooth audio quality
dw com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" int 40
