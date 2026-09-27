{ pkgs, inputs, vars, ... }: {
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  system.stateVersion = 6;

  security.pam.services.sudo_local.touchIdAuth = true;
  # Réattache les sudo imbriqués (brew bundle, home-manager activation-pbear)
  # à la session Touch ID d'origine — sans ça, chaque sous-process de
  # l'activation nix-darwin redemande une authentification séparée.
  security.pam.services.sudo_local.reattach = true;
  # !tty_tickets: share the auth timestamp across all terminals (not per-tty).
  # NOPASSWD for darwin-rebuild: the script calls sudo internally (activate-user),
  # which resets the timestamp and triggers a second Touch ID prompt.
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30, !tty_tickets
    %admin ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';

  # Dock/Finder/trackpad/keyboard-repeat used to live here as system.defaults.*,
  # but overlapped 1:1 with nix-plist-manager (hosts/kamino/mac-settings-system.nix,
  # home/kamino/mac-settings-user.nix) once it was adopted — same plist keys, two
  # sources of truth. Migrated there; screencapture.type has no nix-plist-manager
  # equivalent (only its keyboard shortcuts are covered), so it stays native.
  system.defaults = {
    screencapture.type = "png";
  };

  nix-homebrew = {
    enable = true;
    user = vars.user.name;
  };

  # Ré-indexer Spotlight après chaque rebuild — corrige Alfred qui ne voit
  # pas les apps fraîchement installées par brew cask (bug mv vs Spotlight)
  system.activationScripts.postActivation.text = ''
    echo "Ré-indexation Spotlight de /Applications..." >&2
    for app in /Applications/*.app; do
      [ -e "$app" ] && /usr/bin/mdimport "$app" 2>/dev/null
    done || true
  '';

  homebrew = {
    enable = true;
    onActivation = {
      # update/upgrade décorrélés du rebuild — géré par un agent launchd
      # hebdomadaire (hosts/kamino/default.nix) pour ne pas ralentir nixrb.
      autoUpdate = false;
      cleanup = "zap";
    };
    casks = [];
    # masApps désactivé — prompts Touch ID à chaque rebuild (issue mas CLI)
    # masApps = {
    #   "Mp3tag"                    = 1532597159;
    #   "MediaInfo"                 = 510620098;
    #   "Hover for Safari"          = 1540705431;
    #   "WhatsApp Messenger"        = 310633997;
    #   "News Explorer"             = 1032670789;
    #   "Search Engines for Safari" = 1588019370;
    #   "DeArrow"                   = 6451469297;
    #   "SponsorBlock"              = 1573461917;
    # };
  };

  environment.systemPackages = with pkgs; [
    nano
    bash
    gnused
    coreutils
  ];
}
