{ pkgs, vars, ... }: {
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
    keka
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

  homebrew.casks = [
    "alfred"
    "adguard"
    "microsoft-edge"
    "filebot"
    "keybase"
    "megasync"
    "calibre"
    "telegram"
    "deepl"
    "little-snitch"
    "visual-studio-code"
    "firefox"
    "discord"
    "bitwarden"
  ];
}
