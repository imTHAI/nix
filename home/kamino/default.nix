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

  programs.ssh.matchBlocks."*".extraOptions.UseKeychain = "yes";
}
