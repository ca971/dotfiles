#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/09-apps.sh
# @description App-specific: Activity Monitor, TextEdit, Disk Utility,
#              App Store, Photos, Mail, Calendar, Contacts.
# ============================================================================

# ── Activity Monitor ────────────────────────────────────────────────────────

dw com.apple.ActivityMonitor OpenMainWindow bool true
dw com.apple.ActivityMonitor IconType int 5
dw com.apple.ActivityMonitor ShowCategory int 0
dw com.apple.ActivityMonitor SortColumn string "CPUUsage"
dw com.apple.ActivityMonitor SortDirection int 0
dw com.apple.ActivityMonitor UpdatePeriod int 2

# ── TextEdit ─────────────────────────────────────────────────────────────────

# Plain text by default, UTF-8
dw com.apple.TextEdit RichText int 0
dw com.apple.TextEdit PlainTextEncoding int 4
dw com.apple.TextEdit PlainTextEncodingForWrite int 4

# ── Disk Utility ─────────────────────────────────────────────────────────────

dw com.apple.DiskUtility DUDebugMenuEnabled bool true
dw com.apple.DiskUtility advanced-image-options bool true
dw com.apple.DiskUtility SidebarShowAllDevices bool true

# ── Mac App Store ────────────────────────────────────────────────────────────

dw com.apple.appstore WebKitDeveloperExtras bool true
dw com.apple.appstore ShowDebugMenu bool true

# ── Photos ───────────────────────────────────────────────────────────────────

# Prevent auto-open when devices are plugged in
dw com.apple.ImageCapture disableHotPlug bool true

# ── Mail ─────────────────────────────────────────────────────────────────────

# Copy addresses as "foo@bar.com" not "Name <foo@bar.com>"
dw com.apple.mail AddressesIncludeNameOnPasteboard bool false

# Threaded view, sorted by date descending
dw com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" string "yes"
dw com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" string "yes"
dw com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" string "received-date"

# ── Calendar ─────────────────────────────────────────────────────────────────

# Week starts on Monday
dw com.apple.iCal "first day of week" int 1

# Work hours: 08:00–18:00
dw com.apple.iCal "first minute of work hours" int 480
dw com.apple.iCal "last minute of work hours" int 1080

# Show week numbers
dw com.apple.iCal "Show Week Numbers" bool true

# Default event duration: 60 minutes
dw com.apple.iCal "Default duration" int 60

# ── Contacts ─────────────────────────────────────────────────────────────────

# Sort by first name
dw com.apple.AddressBook ABNameSortingFormat string "sortingFirstName sortingLastName"

# Display: first name first
dw NSGlobalDomain NSPersonNameDefaultDisplayNameOrder int 1
