{ pkgs, lib, vars, ... }: {
  imports = [
    ../common/git.nix
    ../common/ssh.nix
    ../common/zsh.nix
    ../common/starship.nix
    ../common/direnv.nix
    ./gnome.nix
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

  dconf.settings = {
    # RDP goes through the system daemon (Remote Login, see hosts/hoth). Per-user
    # desktop sharing would also try to bind 3389 inside the session.
    "org/gnome/desktop/remote-desktop/rdp".enable = false;
    # Remote-only VM: an idle lock just adds a password prompt on reconnect.
    "org/gnome/desktop/screensaver".lock-enabled = false;
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
