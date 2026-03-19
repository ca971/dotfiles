{
  description = "Node.js project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ nodejs_22 corepack ];
          shellHook = ''
            echo "🟢 Node.js ready — $(node --version)"
            corepack enable 2>/dev/null || true
          '';
        };
      }
    );
}
