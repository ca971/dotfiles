# ============================================================================
# Default dev shell — enter with: nix develop
# ============================================================================
{ pkgs }:

pkgs.mkShell {
  name = "dotfiles-dev";

  buildInputs = with pkgs; [
    # Add project-specific tools here
    nodejs
    python3
    go
    rustup
  ];

  shellHook = ''
    echo "  ❄️  Dev shell ready"
    export EDITOR=nvim
  '';
}
