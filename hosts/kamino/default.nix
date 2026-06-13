{ pkgs, vars, inputs, ... }: {
  imports = [
    ../../system/common.nix
    ../../system/darwin.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "kamino";

  system.primaryUser = vars.user.name;

  users.users.${vars.user.name} = {
    name = vars.user.name;
    home = "/Users/${vars.user.name}";
  };

  system.activationScripts.extraActivation.text = ''
    softwareupdate --install-rosetta --agree-to-license 2>/dev/null || true
    defaults write com.apple.finder WarnOnEmptyTrash -bool false
  '';

  environment.systemPackages = with pkgs; [
    obsidian
    # Build keka via callPackage instead of referencing the flake's packages output:
    # the packages output uses its own pkgs instance whose allowUnfree doesn't
    # propagate from the host config, causing "Refusing to evaluate" at rebuild.
    # callPackage uses the system pkgs (allowUnfree = true from common.nix).
    (pkgs.callPackage "${inputs.nix-packages}/pkgs/keka/package.nix" {})
    iina
    bitwarden-desktop
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

  homebrew.casks = [
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
  ];

  # CLI proxy that filters/compresses command output before it hits the LLM
  # context (~80% token savings on common ops). Wired up via PreToolUse hook
  # in ~/.claude/settings.json (see home/kamino/claude.nix).
  homebrew.masApps = {
    "Telegram" = 747648890;
  };

  homebrew.brews = [ "rtk" ];
}
