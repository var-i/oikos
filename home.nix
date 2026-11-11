{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # ergon.nix (work tools) is added for macos-work only, in flake.nix
  imports = [ ./cli.nix ];
  
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  # ── Firefox ──────────────────────────────────────────────
  programs.firefox = {
    enable = true;
    package = if isDarwin then pkgs.firefox-bin else pkgs.firefox;
    # Work-only Entra SSO policy lives in ergon.nix
    profiles.default = {
      isDefault = true;
      # Profile folder is "default" (the profile name). See README to migrate an existing profile.
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
      ];
    };
  };

  # ── Obsidian ──────────────────────────────────────────────
  programs.obsidian = {
    enable = true;

    vaults.notes.target = "Documents/gnosis";

    defaultSettings.app = {
      alwaysUpdateLinks = true;
      spellcheck = true;
    };
  };

  # ── Thunderbird ──────────────────────────────────────────
  programs.thunderbird = {
    enable = true;
    package = if isDarwin then pkgs.thunderbird-bin else pkgs.thunderbird;
    profiles.default = {
      isDefault = true;
    };
  };

  # ── VSCode ───────────────────────────────────────────────
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default = {
      #"workbench.colorTheme" = "One Dark Pro Darker";
      
      extensions = with pkgs.vscode-extensions; [
        davidanson.vscode-markdownlint
        eamodio.gitlens
        redhat.vscode-yaml
        bbenoist.nix
        esbenp.prettier-vscode
        github.copilot-chat
        ritwickdey.liveserver
        ms-vscode-remote.remote-containers
        ms-azuretools.vscode-containers
        zhuangtongfa.material-theme
        #ionutvmi.path-autocomplete not available for some reason
        christian-kohler.path-intellisense
        rubymaniac.vscode-paste-and-indent
        pkief.material-icon-theme
        ibm.output-colorizer
        github.vscode-github-actions
        #ryu1kn.text-marker not available for some reason
        hashicorp.terraform
        golang.go
        ms-python.python
        #mtxr.sqltools not available in nixpkgs
      ];
    };
  };

  home.packages = [
    pkgs.bitwarden-desktop
    pkgs.opencode-desktop
  ] ++ lib.optionals isDarwin [
    pkgs.rectangle
    # VeraCrypt on macOS comes from Homebrew (darwin.nix); nixpkgs only builds it for Linux
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.veracrypt
  ];
}