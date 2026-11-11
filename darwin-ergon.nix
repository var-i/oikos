{ ... }:

{
  # Work-only casks; merged with the shared list in darwin.nix.
  # Claude desktop (includes the Code tab); no nixpkgs package for macOS
  homebrew.casks = [ "claude" ];
}
