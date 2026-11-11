{ pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # ── Ghostty ──────────────────────────────────────────────
  programs.ghostty = {
    enable = true;
    package = if isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      theme = "Dracula";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;
      window-padding-x = 8;
      window-padding-y = 8;
      window-decoration = if isDarwin then "auto" else "server";
      cursor-style = "block";
      cursor-style-blink = true;
      copy-on-select = "clipboard";
      confirm-close-surface = false;
      shell-integration = "zsh";
      macos-option-as-alt = true;
    };
  };

  # ── Micro ────────────────────────────────────────────────
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "dracula-tc";
    };
  };
  # micro doesn't have a defaultEditor option, so set $EDITOR ourselves
  home.sessionVariables.EDITOR = "micro";

  # ── Zsh ──────────────────────────────────────────────────
  programs.zsh = {   
   enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };
    shellAliases = {
      ll = "eza -la --icons --git";
      ls = "eza --icons";
      lt = "eza --tree --icons --level=2";
      cat = "bat";
      grep = "rg";
      find = "fd";
      top = "btop";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
    # Put Homebrew on PATH for the normal user (Apple Silicon installs to /opt/homebrew)
    initContent = lib.optionalString isDarwin ''
      if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    '';
    # Don't need because of atuin
    #initExtra = ''
    #  # Better keybindings
    #  bindkey '^[[A' history-search-backward
    #  bindkey '^[[B' history-search-forward
    #'';
  };

  # ── Starship prompt ─────────────────────────────────────
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      palette = "dracula";
      palettes.dracula = {
        background = "#282a36";
        foreground = "#f8f8f2";
        cyan = "#8be9fd";
        green = "#50fa7b";
        orange = "#ffb86c";
        pink = "#ff79c6";
        purple = "#bd93f9";
        red = "#ff5555";
        yellow = "#f1fa8c";
      };
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      directory = {
        style = "cyan bold";
        truncation_length = 4;
      };
      git_branch = {
        style = "pink";
        symbol = " ";
      };
      git_status.style = "red";
    };
  };

  programs.delta = {
      enable = true;   # Beautiful diffs in terminal
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
  };

  # ── Modern CLI tools ─────────────────────────────────────
  programs.bat = {
    enable = true;
    config.theme = "Dracula";
  };

  programs.eza.enable = true;        # Modern ls
  programs.ripgrep.enable = true;    # Modern grep
  programs.fd.enable = true;         # Modern find
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9"
      "--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9"
      "--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6"
      "--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
    ];
  };
  programs.zoxide = {
    enable = true;                   # Smart cd (z command)
    enableZshIntegration = true;
  };
  programs.btop = {
    enable = true;
    settings.color_theme = "dracula";
  };
  programs.jq.enable = true;        # JSON processor
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;       # Fast nix-shell integration
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = false;
      update_check = false;
      search_mode = "fuzzy";
      style = "compact";
      enter_accept = true;
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # ── Extra packages ──────────────────────────────────────
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono         # Font for Ghostty/terminal
    tldr                              # Simplified man pages
    httpie                            # Modern curl
    dust                              # Modern du (disk usage)
    duf                               # Modern df
    procs                             # Modern ps
    tokei                             # Count lines of code
    hyperfine                         # Benchmarking tool
    wget
    unzip
  ];

}