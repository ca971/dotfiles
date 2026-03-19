# Custom package overlays
final: prev: {
  # Example: pin a specific version
  # my-custom-tool = prev.my-tool.overrideAttrs (old: {
  #   version = "1.2.3";
  #   src = prev.fetchFromGitHub { ... };
  # });
}
