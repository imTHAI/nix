{ pkgs, vars, ... }: {
  imports = [
    ../common/git.nix
    ../common/ssh.nix
    ../common/zsh.nix
    ../common/starship.nix
    ../common/direnv.nix
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.username      = vars.user.name;
  home.homeDirectory = "/home/${vars.user.name}";

  home.packages = pkgs.callPackage ./packages.nix { };

  programs.zsh.shellAliases = {
    nixup   = "_nixupdate jakku nixos-rebuild";
    nixrb   = "_nixrebuild jakku nixos-rebuild";
    # nix flake archive prefetches inputs as the user: the sudo'd rebuild would
    # otherwise fetch git+ssh inputs (nix-private) as root, whose ssh has no key.
    nixpull = "cd ~/.config/nix && git pull && nix flake archive && sudo nixos-rebuild switch --flake ~/.config/nix#jakku";
  };
}
