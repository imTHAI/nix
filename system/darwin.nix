{ pkgs, inputs, vars, ... }: {
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  system.stateVersion = 6;

  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 3; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      launchanim = false;
      mineffect = "scale";
      minimize-to-application = true;
      mru-spaces = false;
      show-recents = false;
      showhidden = true;
    };
    finder = {
      FXPreferredViewStyle = "Nlsv";
      ShowStatusBar = true;
      ShowPathbar = true;
      QuitMenuItem = true;
      _FXSortFoldersFirst = true;
      FXEnableExtensionChangeWarning = false;
    };
    NSGlobalDomain = {
      KeyRepeat = 6;
      InitialKeyRepeat = 25;
      AppleShowAllExtensions = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
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
    /usr/bin/mdimport /Applications/*.app 2>/dev/null || true
  '';

  homebrew = {
    enable = true;
    onActivation = {
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
