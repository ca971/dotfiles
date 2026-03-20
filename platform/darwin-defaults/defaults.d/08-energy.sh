#!/usr/bin/env bash
# ============================================================================
# @file        defaults.d/08-energy.sh
# @description Energy Saver: sleep, display, Power Nap, wake, hibernation.
# ============================================================================

if $_MACOS_DRY_RUN; then
    _info "[DRY-RUN] Energy settings require sudo — skipping"
    return 0
fi

# ── Sleep ────────────────────────────────────────────────────────────────────

# No sleep on power adapter
sudo pmset -c sleep 0 2> /dev/null || true

# Display sleep: 15min (power), 5min (battery)
sudo pmset -c displaysleep 15 2> /dev/null || true
sudo pmset -b displaysleep 5 2> /dev/null || true

# Computer sleep: 10min (battery)
sudo pmset -b sleep 10 2> /dev/null || true

# ── Power Nap ────────────────────────────────────────────────────────────────

# Power Nap on adapter only
sudo pmset -c powernap 1 2> /dev/null || true
sudo pmset -b powernap 0 2> /dev/null || true

# ── Wake ─────────────────────────────────────────────────────────────────────

# Wake on network access (power adapter)
sudo pmset -c womp 1 2> /dev/null || true

# ── Hibernation ──────────────────────────────────────────────────────────────

# 0=RAM only, 3=safe sleep (default), 25=hibernate
sudo pmset -a hibernatemode 3 2> /dev/null || true
