# ============================================================================
# macOS-specific packages
# ============================================================================
{ pkgs }:

with pkgs; [
  coreutils
  findutils
  gnugrep
  gnused
  gawk
  gnutar # pas gnu-tar
  pinentry_mac
]
