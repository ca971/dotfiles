#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/03-finder.sh
# @description Finder: views, extensions, .DS_Store, Quick Look, AirDrop.
# ============================================================================

# ── Finder Window ────────────────────────────────────────────────────────────

# New window opens home folder
dw com.apple.finder NewWindowTarget string "PfHm"
dw com.apple.finder NewWindowTargetPath string "file://${HOME}/"

# Show path bar
dw com.apple.finder ShowPathbar bool true

# Show status bar
dw com.apple.finder ShowStatusBar bool true

# Show tab bar
dw com.apple.finder ShowTabView bool true

# Full POSIX path in title bar
dw com.apple.finder _FXShowPosixPathInTitle bool true

# ── View Options ─────────────────────────────────────────────────────────────

# Default view: Nlsv=List, icnv=Icon, clmv=Column, glyv=Gallery
dw com.apple.finder FXPreferredViewStyle string "clmv"

# Keep folders on top when sorting
dw com.apple.finder _FXSortFoldersFirst bool true
dw com.apple.finder _FXSortFoldersFirstOnDesktop bool true

# ── Search ───────────────────────────────────────────────────────────────────

# Search current folder by default
dw com.apple.finder FXDefaultSearchScope string "SCcf"

# ── Files & Extensions ───────────────────────────────────────────────────────

# Show all filename extensions
dw NSGlobalDomain AppleShowAllExtensions bool true

# Disable extension change warning
dw com.apple.finder FXEnableExtensionChangeWarning bool false

# Show hidden files
dw com.apple.finder AppleShowAllFiles bool true

# ── Desktop ──────────────────────────────────────────────────────────────────

# Show external drives
dw com.apple.finder ShowExternalHardDrivesOnDesktop bool true

# Hide internal drives
dw com.apple.finder ShowHardDrivesOnDesktop bool false

# Show mounted servers
dw com.apple.finder ShowMountedServersOnDesktop bool true

# Show removable media
dw com.apple.finder ShowRemovableMediaOnDesktop bool true

# ── Behavior ─────────────────────────────────────────────────────────────────

# Disable Trash empty warning
dw com.apple.finder WarnOnEmptyTrash bool false

# Avoid .DS_Store on network volumes
dw com.apple.desktopservices DSDontWriteNetworkStores bool true

# Avoid .DS_Store on USB volumes
dw com.apple.desktopservices DSDontWriteUSBStores bool true

# ── Disk Images ──────────────────────────────────────────────────────────────

# Skip disk image verification
dw com.apple.frameworks.diskimages skip-verify bool true
dw com.apple.frameworks.diskimages skip-verify-locked bool true
dw com.apple.frameworks.diskimages skip-verify-remote bool true

# Auto-open windows for mounted volumes
dw com.apple.frameworks.diskimages auto-open-ro-root bool true
dw com.apple.frameworks.diskimages auto-open-rw-root bool true
dw com.apple.finder OpenWindowForNewRemovableDisk bool true

# ── Animations ───────────────────────────────────────────────────────────────

# Disable Finder animations
dw com.apple.finder DisableAllAnimations bool true

# Spring loading with no delay
dw NSGlobalDomain com.apple.springing.enabled bool true
dw NSGlobalDomain com.apple.springing.delay float 0

# ── Quick Look ───────────────────────────────────────────────────────────────

# Allow text selection in Quick Look
dw com.apple.finder QLEnableTextSelection bool true

# ── AirDrop ──────────────────────────────────────────────────────────────────

# AirDrop over every interface
dw com.apple.NetworkBrowser BrowseAllInterfaces bool true
