{ pkgs, vars, ... }: {
  imports = [
    ../common/git.nix
    ../common/ssh.nix
    ../common/zsh.nix
    ../common/starship.nix
    ../common/direnv.nix
  ];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  manual.manpages.enable = false;

  home.username      = vars.user.name;
  home.homeDirectory = "/home/${vars.user.name}";

  home.packages = pkgs.callPackage ./packages.nix { };

  programs.zsh.shellAliases = {
    nixup   = "cd ~/.config/nix && nix flake update && git add flake.lock && git commit -m 'chore: flake update' && home-manager switch --flake ~/.config/nix#pbear@scarif && git push";
    nixrb   = "cd ~/.config/nix && git add -A && home-manager switch --flake ~/.config/nix#pbear@scarif && git push";
    nixpull = "cd ~/.config/nix && git pull && home-manager switch --flake ~/.config/nix#pbear@scarif";
  };
}
