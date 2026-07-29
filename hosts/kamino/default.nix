{ pkgs, vars, inputs, ... }: {
  imports = [
    ../../system/common.nix
    ../../system/darwin.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "kamino";

  # Hands Nix installation/config management to Determinate Nixd instead of
  # nix-darwin (sets nix.enable = false internally). GC becomes disk-space-
  # threshold-based (5-20% free, 30GB floor) rather than the fixed weekly
  # schedule previously set via nix.gc below; nix.optimise.automatic (store
  # dedup, pure disk-space optimization, no functional impact) has no
  # equivalent here and is simply dropped.
  determinateNix.enable = true;

  system.primaryUser = vars.user.name;

  users.users.${vars.user.name} = {
    name = vars.user.name;
    home = "/Users/${vars.user.name}";
  };

  system.activationScripts.extraActivation.text = ''
    /usr/bin/pgrep oahd >/dev/null 2>&1 || softwareupdate --install-rosetta --agree-to-license 2>/dev/null || true
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
    # Whitelist unsigned/non-notarized apps so Gatekeeper doesn't block them on first launch.
    # spctl --add is idempotent and safe to run on already-approved apps.
    spctl --add "/Applications/Nix Apps/Supacode.app" 2>/dev/null || true
  '';

  environment.systemPackages = with pkgs; [
    # Build keka via callPackage instead of referencing the flake's packages output:
    # the packages output uses its own pkgs instance whose allowUnfree doesn't
    # propagate from the host config, causing "Refusing to evaluate" at rebuild.
    # callPackage uses the system pkgs (allowUnfree = true from common.nix).
    (pkgs.callPackage "${inputs.nix-packages}/pkgs/keka/package.nix" {})
    (pkgs.callPackage "${inputs.nix-packages}/pkgs/hipixel/package.nix" {})
    (pkgs.callPackage "${inputs.nix-packages}/pkgs/mist/package.nix" {})
    (pkgs.callPackage "${inputs.nix-packages}/pkgs/supacode/package.nix" {})
    appcleaner
    iina
    nerd-fonts.hack
    docker
    colima
  ];

  launchd.user.agents.colima = {
    serviceConfig = {
      ProgramArguments = [ "/bin/sh" "-c" "/run/current-system/sw/bin/colima start" ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/colima-launch.log";
      StandardErrorPath = "/tmp/colima-launch-error.log";
    };
  };

  # Casks (cmux, etc.) ne sont mis à jour par nixrb que si autoUpdate=true
  # (désactivé, voir system/darwin.nix) — sans quoi ils restent figés sur le
  # cache brew local. Cet agent fait le travail une fois par semaine plutôt
  # qu'à chaque rebuild.
  #
  # Étapes séparées par ";" (pas "&&") : certains casks (ex. little-snitch,
  # extension système) utilisent un installeur pkg privilégié qui exige un
  # sudo interactif. Sans TTY (agent launchd), ce sudo échoue proprement et
  # immédiatement — pas de hang — mais un "&&" aurait annulé le cleanup final
  # à cause de ce seul échec. Chaque étape tourne donc indépendamment.
  launchd.user.agents.brewWeeklyUpgrade = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh" "-c"
        "/opt/homebrew/bin/brew update; /opt/homebrew/bin/brew upgrade --cask --greedy; /opt/homebrew/bin/brew cleanup"
      ];
      StartCalendarInterval = [{ Weekday = 6; Hour = 0; Minute = 0; }];
      StandardOutPath = "/tmp/brew-weekly-upgrade.log";
      StandardErrorPath = "/tmp/brew-weekly-upgrade-error.log";
    };
  };

  homebrew.casks = [
    "flutter"
    "cmux"
    "alfred"
    "adguard"
    "microsoft-edge"
    "filebot"
    "keybase"
    "megasync"
    "calibre"
    "deepl"
    "little-snitch"
    "visual-studio-code"
    "firefox"
    "discord"
    "bitwarden"
    # nixpkgs telegram-desktop builds from source on aarch64-darwin (no Hydra
    # cache) and takes hours — the cask ships the official prebuilt app.
    "telegram"
  ];

  # CLI proxy that filters/compresses command output before it hits the LLM
  # context (~80% token savings on common ops). Wired up via PreToolUse hook
  # in ~/.claude/settings.json (see home/kamino/claude.nix).
  homebrew.brews = [ "rtk" ];
}
