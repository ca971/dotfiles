#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/01-general.sh
# @description System-wide macOS preferences: appearance, UI behavior,
#              text input, locale, menu bar, sound.
# @note        Sourced by apply.sh — `dw` and `dd` functions are available.
# ============================================================================

# ── Appearance ───────────────────────────────────────────────────────────────

# Dark mode
dw NSGlobalDomain AppleInterfaceStyle string "Dark"

# Accent color: Graphite
dw NSGlobalDomain AppleAccentColor int -1

# Highlight color: Graphite
dw NSGlobalDomain AppleHighlightColor string "0.847059 0.847059 0.862745 Graphite"

# Sidebar icon size: Medium (1=Small, 2=Medium, 3=Large)
dw NSGlobalDomain NSTableViewDefaultSizeMode int 2

# Scrollbar visibility: WhenScrolling | Automatic | Always
dw NSGlobalDomain AppleShowScrollBars string "Automatic"

# ── UI Behavior ──────────────────────────────────────────────────────────────

# Expand save panel by default
dw NSGlobalDomain NSNavPanelExpandedStateForSaveMode bool true
dw NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 bool true

# Expand print panel by default
dw NSGlobalDomain PMPrintingExpandedStateForPrint bool true
dw NSGlobalDomain PMPrintingExpandedStateForPrint2 bool true

# Save to disk (not iCloud) by default
dw NSGlobalDomain NSDocumentSaveNewDocumentsToCloud bool false

# Auto-quit printer app when jobs complete
dw com.apple.print.PrintingPrefs "Quit When Finished" bool true

# Disable "Are you sure you want to open this application?"
dw com.apple.LaunchServices LSQuarantine bool false

# Disable automatic termination of inactive apps
dw NSGlobalDomain NSDisableAutomaticTermination bool true

# Disable Resume system-wide
dw com.apple.systempreferences NSQuitAlwaysKeepsWindows bool false

# ── Window Management ────────────────────────────────────────────────────────

# Smooth scrolling
dw NSGlobalDomain NSScrollAnimationEnabled bool true

# Faster window resize for Cocoa apps
dw NSGlobalDomain NSWindowResizeTime float 0.001

# Spring loading for directories (drag hover to open)
dw NSGlobalDomain com.apple.springing.enabled bool true
dw NSGlobalDomain com.apple.springing.delay float 0.5

# ── Text & Typing ────────────────────────────────────────────────────────────

# Disable automatic capitalization
dw NSGlobalDomain NSAutomaticCapitalizationEnabled bool false

# Disable smart dashes
dw NSGlobalDomain NSAutomaticDashSubstitutionEnabled bool false

# Disable automatic period substitution
dw NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled bool false

# Disable smart quotes
dw NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled bool false

# Disable auto-correct
dw NSGlobalDomain NSAutomaticSpellingCorrectionEnabled bool false

# Enable text completion
dw NSGlobalDomain NSAutomaticTextCompletionEnabled bool true

# ── Locale ───────────────────────────────────────────────────────────────────

# Language and text formats
dw NSGlobalDomain AppleLanguages -array "en-FR" "fr-FR"
dw NSGlobalDomain AppleLocale string "en_FR"
dw NSGlobalDomain AppleMeasurementUnits string "Centimeters"
dw NSGlobalDomain AppleMetricUnits bool true

# 24-hour time
dw NSGlobalDomain AppleICUForce24HourTime bool true

# ── Menu Bar Clock ───────────────────────────────────────────────────────────

# Date format: "EEE d MMM HH:mm:ss"
dw com.apple.menuextra.clock DateFormat string "EEE d MMM HH:mm:ss"
dw com.apple.menuextra.clock ShowSeconds bool true

# ── Sound ────────────────────────────────────────────────────────────────────

# Disable UI sound effects
dw NSGlobalDomain com.apple.sound.uiaudio.enabled bool false

# Disable startup chime
if ! $_MACOS_DRY_RUN; then
    sudo nvram SystemAudioVolume=" " 2> /dev/null || true
fi
