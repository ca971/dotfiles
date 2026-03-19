{ pkgs }:

pkgs.mkShell {
  name = "node-dev";

  buildInputs = with pkgs; [
    # Node.js LTS
    nodejs_22
    corepack # pnpm, yarn

    # Tools
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.prettier

    # Build deps
    python3 # For node-gyp
    gcc
  ];

  env = {
    NODE_ENV = "development";
  };

  shellHook = ''
    echo "  🟢 Node.js dev shell"
    echo "  $(node --version)"
    echo "  $(npm --version)"
    # Enable corepack for pnpm/yarn
    corepack enable 2>/dev/null || true
  '';
}
