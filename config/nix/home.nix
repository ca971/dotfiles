# ============================================================================
# Home Manager configuration — declarative dotfile management
# @see https://nix-community.github.io/home-manager/
#
# This is OPTIONAL — our dotfiles already manage everything.
# Use this if you want Nix to manage additional configs.
# ============================================================================
{ config, pkgs, ... }:

{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # ── Shell integration ──────────────────────────────────────────────
  # NOTE: We don't configure shells here — our dotfiles handle that.
  # This section is for Nix-specific shell features only.

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Faster nix-shell via direnv
  };

  # ── Git (managed by dotfiles, but Nix can ensure it's installed) ──
  programs.git.enable = true;

  # ── Environment variables ──────────────────────────────────────────
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    LANG = "en_US.UTF-8";
  };
}
