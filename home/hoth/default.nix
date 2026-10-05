{ pkgs, vars, ... }: {
  imports = [
    ../common/git.nix
    ../common/ssh.nix
    ../common/zsh.nix
    ../common/starship.nix
    ../common/direnv.nix
    ./plasma.nix
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.username      = vars.user.name;
  home.homeDirectory = "/home/${vars.user.name}";

  home.packages = pkgs.callPackage ../common/packages.nix { } ++ [
    # Agent CLI for zeron. Its in-app installer fetches the generic Linux build
    # (curl claude.ai/install.sh), which NixOS can't run without nix-ld; zeron
    # picks `claude` up from PATH instead.
    pkgs.claude-code
  ];

  programs.zsh.shellAliases = {
    nixup   = "_nixupdate hoth nixos-rebuild";
    nixrb   = "_nixrebuild hoth nixos-rebuild";
    # nix flake archive prefetches inputs as the user: the sudo'd rebuild would
    # otherwise fetch git+ssh inputs (nix-private) as root, whose ssh has no key.
    nixpull = "cd ~/.config/nix && git pull && nix flake archive && sudo nixos-rebuild switch --flake ~/.config/nix#hoth";
  };
}
