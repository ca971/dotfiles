# ============================================================================
# @file        config/nix/flake.nix
# @description Nix Flake — declarative cross-platform environment.
#              Installs identical tools on macOS and Linux.
#
# @usage       cd ~/dotfiles/config/nix
#              nix develop              # Enter dev shell
#              nix profile install .    # Install all packages
#              nix flake update         # Update all inputs
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @version     1.0.0
# ============================================================================
{
  description = "Dotfiles Enterprise — Cross-platform development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, darwin, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        commonPackages = import ./packages/common.nix { inherit pkgs; };

        platformPackages =
          if pkgs.stdenv.isDarwin
          then import ./packages/darwin.nix { inherit pkgs; }
          else import ./packages/linux.nix { inherit pkgs; };

        allPackages = commonPackages ++ platformPackages;

      in
      {
        # ── Dev shell (nix develop) ──────────────────────────────────
        devShells.default = pkgs.mkShell {
          name = "dotfiles-dev";
          buildInputs = allPackages;

          shellHook = ''
            echo ""
            echo "  ❄️  Nix dev shell activated"
            echo "  Platform: ${system}"
            echo "  Packages: ${toString (builtins.length allPackages)} tools"
            echo ""
          '';
        };

        # ── Package bundle (nix profile install) ─────────────────────
        packages.default = pkgs.buildEnv {
          name = "dotfiles-env";
          paths = allPackages;
          pathsToLink = [ "/bin" "/share" "/etc" ];
        };
      }
    );
}
