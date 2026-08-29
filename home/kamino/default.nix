{ lib, vars, ... }: {
  imports = [
    ../common/git.nix
    ../common/ssh.nix
    ../common/zsh.nix
    ../common/starship.nix
    ../common/direnv.nix
    ./shell.nix
    ./apps.nix
    ./firefox.nix
    ./claude.nix
    ./cmux.nix
    ./calibre.nix
    ./devonthink.nix
    ./listcrush-backup.nix
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  # Avoids the upstream "options.json references store path without a proper
  # context" eval warning (nixpkgs#485682) — the manual's option-doc build
  # uses builtins.toFile + unsafeDiscardStringContext internally. Disabling
  # doc generation sidesteps it entirely; we don't consult these docs locally.
  manual.html.enable     = false;
  manual.manpages.enable = false;
  manual.json.enable     = false;

  # Discord webhook used by the autoUpgrade report job (and reusable for any
  # other local notification script) — decrypted at activation, age key already
  # configured in claude.nix.
  # Secrets declared here: discord_webhook_url only.
  # exa_api_key, upstash_url, upstash_token, username, password → claude.nix
  # (declared alongside the activation scripts that consume them)
  sops.secrets."discord_webhook_url" = {
    sopsFile = ../../secrets/kamino/discord.yaml;
    key = "webhook_url"; # actual key name inside discord.yaml
  };

  home.username    = vars.user.name;
  home.homeDirectory = "/Users/${vars.user.name}";

  home.sessionVariables.CLAUDE_SKIP_UPGRADE_WARNING = "1";

  home.activation.createMountPoints = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/homedir-pbear"
    mkdir -p "$HOME/downloads_unraid"
    mkdir -p "$HOME/media"
  '';

  # sops-nix LaunchAgent declares StandardErrorPath/StandardOutPath under
  # ~/Library/Logs/SopsNix/. launchd refuses to bootstrap a service whose log
  # parent dir doesn't exist (Bootstrap failed: 5: Input/output error), so the
  # dir must exist *before* the sops-nix activation step runs.
  home.activation.createSopsNixLogDir = lib.hm.dag.entryBefore [ "sops-nix" ] ''
    mkdir -p "$HOME/Library/Logs/SopsNix"
  '';

  programs.ssh.settings."*".UseKeychain = "yes";
}
