{ pkgs, lib, inputs, ... }: {
  imports = [
    ../../system/common.nix
    inputs.nixos-wsl.nixosModules.default
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  wsl = {
    enable = true;
    defaultUser = "bcrevin";
  };

  # Certificat Zscaler pour Nix derrière proxy entreprise
  security.pki.certificateFiles = [ ./zscaler.pem ];
  nix.settings.ssl-cert-file = "/etc/ssl/certs/ca-bundle.crt";

  users.users.bcrevin = {
    isNormalUser = true;
    extraGroups  = [ "wheel" ];
    shell        = pkgs.zsh;
  };

  programs.zsh.enable = true;

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";

  system.stateVersion = "25.05";
}
