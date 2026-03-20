#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/04-safari.sh
# @description Safari & WebKit: privacy, developer tools, tabs, security.
# ============================================================================

# ── Privacy ──────────────────────────────────────────────────────────────────

# Don't send search queries to Apple
dw com.apple.Safari UniversalSearchEnabled bool false
dw com.apple.Safari SuppressSearchSuggestions bool true

# Don't auto-open "safe" downloads
dw com.apple.Safari AutoOpenSafeDownloads bool false

# ── UI ───────────────────────────────────────────────────────────────────────

# Show full URL in address bar
dw com.apple.Safari ShowFullURLInSmartSearchField bool true

# Blank home page
dw com.apple.Safari HomePage string "about:blank"

# Show favorites bar
dw com.apple.Safari ShowFavoritesBar-v2 bool true

# ── Tabs ─────────────────────────────────────────────────────────────────────

# Compact tab layout
dw com.apple.Safari ShowStandaloneTabBar bool false

# New tabs/windows open with empty page
dw com.apple.Safari NewTabBehavior int 1
dw com.apple.Safari NewWindowBehavior int 1

# ── Developer ────────────────────────────────────────────────────────────────

# Enable Develop menu
dw com.apple.Safari IncludeDevelopMenu bool true
dw com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey bool true
dw com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled bool true

# Web Inspector in all web views
dw NSGlobalDomain WebKitDeveloperExtras bool true

# ── Security ─────────────────────────────────────────────────────────────────

# Warn about fraudulent websites
dw com.apple.Safari WarnAboutFraudulentWebsites bool true

# Enable Do Not Track
dw com.apple.Safari SendDoNotTrackHTTPHeader bool true

# Block pop-ups
dw com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically bool false
dw com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically bool false

# ── Debug & Updates ──────────────────────────────────────────────────────────

# Enable debug menu
dw com.apple.Safari IncludeInternalDebugMenu bool true

# Auto-update extensions
dw com.apple.Safari InstallExtensionUpdatesAutomatically bool true
