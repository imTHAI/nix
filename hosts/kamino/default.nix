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
