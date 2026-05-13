{ pkgs, lib, vars, ... }: {
  imports = [
    ../../system/common.nix
    ./hardware.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl = {
    "net.ipv6.conf.enp2s0.accept_ra" = 0;
    "net.ipv6.conf.enp2s0.addr_gen_mode" = 1;
    "net.ipv6.conf.enp2s0.use_tempaddr" = lib.mkForce 0;
  };

  networking = {
    hostName = "jakku";
    networkmanager.enable = false;
    defaultGateway = "10.0.0.1";
    defaultGateway6 = {
      address = "2001:db8:aaa:e22::1";
      interface = "enp2s0";
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    interfaces.enp2s0 = {
      ipv4.addresses = [{ address = "10.0.0.18"; prefixLength = 24; }];
      ipv6.addresses = [{ address = "2001:db8:aaa:e22:10:0:2:18"; prefixLength = 64; }];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
      allowPing = true;
    };
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT    = "fr_FR.UTF-8";
    LC_MONETARY       = "fr_FR.UTF-8";
    LC_NAME           = "fr_FR.UTF-8";
    LC_NUMERIC        = "fr_FR.UTF-8";
    LC_PAPER          = "fr_FR.UTF-8";
    LC_TELEPHONE      = "fr_FR.UTF-8";
    LC_TIME           = "fr_FR.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
  };

  users.users.${vars.user.name} = {
    isNormalUser = true;
    description = vars.user.fullname;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  programs.nano = {
    enable = true;
    syntaxHighlight = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[λ](bold green) ";
        error_symbol = "[λ](bold red) ";
      };
      hostname = {
        ssh_only = true;
        format = "sur [$hostname](bold magenta) ";
      };
    };
  };

  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  security.sudo.extraRules = [{
    users = [ vars.user.name ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  system.stateVersion = "25.11";
}
