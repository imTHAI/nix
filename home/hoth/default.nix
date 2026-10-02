{ pkgs, lib, vars, ... }: {
  imports = [
    ../common/git.nix
    ../common/ssh.nix
    ../common/zsh.nix
    ../common/starship.nix
    ../common/direnv.nix
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  home.username      = vars.user.name;
  home.homeDirectory = "/home/${vars.user.name}";

  home.packages = pkgs.callPackage ../common/packages.nix { };

  # gnome-remote-desktop's desktop sharing silently stalls after auth while the
  # session is locked (gnome-shell refuses screencast on the lock screen). This
  # is a VM with no one at its console, so locking only gets in the way of RDP.
  programs.gnome-shell = {
    enable = true;
    extensions = [{ package = pkgs.gnomeExtensions.allow-locked-remote-desktop; }];
  };
  dconf.settings = {
    "org/gnome/desktop/screensaver".lock-enabled = false;
    # Blanking also blocks new RDP connections; 0 disables the idle timer.
    "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 0;
  };

  programs.zsh.shellAliases = {
    nixup   = "_nixupdate hoth nixos-rebuild";
    nixrb   = "_nixrebuild hoth nixos-rebuild";
    # nix flake archive prefetches inputs as the user: the sudo'd rebuild would
    # otherwise fetch git+ssh inputs (nix-private) as root, whose ssh has no key.
    nixpull = "cd ~/.config/nix && git pull && nix flake archive && sudo nixos-rebuild switch --flake ~/.config/nix#hoth";
  };
}
