{ pkgs, lib, username, ... }:

{

  # ── Primary user (required for system.defaults) ─────────
  system.primaryUser = username;

  # ── Nix settings ────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" username ];
  };

  # ── macOS system defaults ───────────────────────────────
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      minimize-to-application = true;
      show-recents = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
      "com.apple.swipescrolldirection" = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
  };

  # ── Homebrew (casks with no usable nixpkgs build) ──────
  # Only manages Homebrew; it does not install it. If brew is missing,
  # activation prints an error and skips this step.
  homebrew = {
    enable = true;
    casks = [
      # FUSE-T build: no kernel extension needed (pulls in the fuse-t cask)
      "veracrypt-fuse-t"
    ];
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
    };
  };

  # ── Security ────────────────────────────────────────────
  security.pam.services.sudo_local.touchIdAuth = true;

  # ── User ────────────────────────────────────────────────
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # ── Platform ────────────────────────────────────────────
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Used for backwards compatibility
  system.stateVersion = 6;
}