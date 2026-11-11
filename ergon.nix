{ pkgs, ... }:

# Work-only home-manager settings. Imported for `macos-work` only (see flake.nix).
# Options here merge with the shared ones in home.nix and cli.nix.
{
  # ── Firefox ──────────────────────────────────────────────
  # Entra SSO (sends device ID / PRT); locked so it can't be changed in about:config
  programs.firefox.policies.Preferences."network.http.microsoft-entra-sso.enabled" = {
    Value = true;
    Status = "locked";
  };

  # ── Kubernetes ───────────────────────────────────────────
  programs.k9s = {
    enable = true;
    settings.k9s.ui.skin = "one-dark";
    skins."one-dark" = "${pkgs.k9s}/share/k9s/skins/one-dark.yaml";
  };

  programs.zsh.shellAliases = {
    k = "kubectl";
    kns = "kubens";
    kctx = "kubectx";
  };

  home.packages = with pkgs; [
    # cloud
    awscli2
    azure-cli
    saml2aws
    terraform

    # kubernetes
    kubectl
    kubectx
    kubernetes-helm

    ## Python / MCP tooling
    uv

    ## Go development
    go
    golangci-lint
    delve
    gopls
    golangci-lint-langserver
    templ
    go-migrate

    ## Work platform CLI
    openshift
  ];
}
