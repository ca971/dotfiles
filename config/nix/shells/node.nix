{ pkgs }:

pkgs.mkShell {
  name = "node-dev";

  buildInputs = with pkgs; [
    nodejs_22
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.prettier
    nodePackages.pnpm
  ];

  env = {
    NODE_ENV = "development";
  };

  shellHook = ''
    echo "  🟢 Node.js dev shell"
    echo "  $(node --version)"
    echo "  $(npm --version)"
  '';
}
