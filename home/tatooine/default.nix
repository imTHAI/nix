{ pkgs, ... }: {
  imports = [
    ../common/git.nix
    ../common/ssh.nix
    ../common/zsh.nix
    ../common/starship.nix
    ../common/direnv.nix
  ];

  home.stateVersion  = "25.05";
  programs.home-manager.enable = true;

  home.username      = "bcrevin";
  home.homeDirectory = "/home/bcrevin";

  home.packages = pkgs.callPackage ./packages.nix { };

  programs.zsh.shellAliases = {
    nixup   = "_nixupdate tatooine nixos-rebuild";
    nixrb   = "_nixrebuild tatooine nixos-rebuild";
    nixpull = "cd ~/.config/nix && git pull && sudo nixos-rebuild switch --flake ~/.config/nix#tatooine";
  };
}
