{
  description = "Python project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ python313 python313Packages.pip uv ruff ];
          shellHook = ''
            echo "🐍 Python ready — $(python --version)"
            [ ! -d .venv ] && python -m venv .venv
            source .venv/bin/activate
          '';
        };
      }
    );
}
