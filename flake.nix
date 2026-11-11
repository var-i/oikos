{
  description = "THE cross-platform oikos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    mac-app-util.url = "github:hraban/mac-app-util";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";
  };

  outputs = { nixpkgs, home-manager, nix-darwin, nur, mac-app-util, ... }:
    let
      # No usernames are committed: they are read from the environment at
      # evaluation time, which only works with `--impure`.
      envOrThrow = var:
        let value = builtins.getEnv var; in
        if value != "" then value
        else throw "${var} is empty. Evaluate with --impure (on macOS also pass it through sudo: `sudo env ${var}=<user> ...`).";

      # ── macOS ─────────────────────────────────────────────
      mkDarwinSystem = { isWork ? false }:
        let username = envOrThrow "NIX_USER"; in
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username; };
          modules = [
            ./darwin.nix
          ]
          ++ nixpkgs.lib.optionals isWork [ ./darwin-ergon.nix ]
          ++ [
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ nur.overlays.default ];

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.sharedModules = [
                mac-app-util.homeManagerModules.default
              ];

              home-manager.users.${username} = {
                # mac-app-util trampolines conflict with device management
                # on the work Mac, so use plain symlinked apps instead.
                targets.darwin.mac-app-util.enable = false;
                targets.darwin.linkApps.enable = true;
                targets.darwin.copyApps.enable = false;
                imports = [ ./home.nix ]
                  ++ nixpkgs.lib.optionals isWork [ ./ergon.nix ];
              };
            }
          ];
        };

      # ── Linux (non-NixOS, standalone home-manager) ────────
      mkHome = system:
        let username = envOrThrow "USER"; in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ nur.overlays.default ];
          };
          modules = [
            ./home.nix
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              # Non-NixOS: XDG dirs, desktop entries and GPU driver integration for every GUI app.
              targets.genericLinux.enable = true;
            }
          ];
        };
    in
    {
      darwinConfigurations."macos-aarch64" = mkDarwinSystem { };
      darwinConfigurations."macos-work" = mkDarwinSystem { isWork = true; };

      homeConfigurations = {
        "linux" = mkHome "x86_64-linux";
        "linux-aarch64" = mkHome "aarch64-linux";
      };
    };
}
