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
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

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

  programs.ssh.matchBlocks."*".extraOptions.UseKeychain = "yes";
}
