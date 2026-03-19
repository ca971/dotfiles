# ============================================================================
# Linux-specific packages
# ============================================================================
{ pkgs }:

with pkgs; [
  # ── Linux System ──────────────────────────────────────────────────
  iproute2 # ip command
  procps # ps, free, etc.
  util-linux # lsblk, mount, etc.

  # ── Clipboard ──────────────────────────────────────────────────────
  xclip
  wl-clipboard # Wayland

  # ── Notifications ──────────────────────────────────────────────────
  libnotify # notify-send

  # ── File Systems ───────────────────────────────────────────────────
  ntfs3g # NTFS support
]
