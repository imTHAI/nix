{ pkgs, lib, vars, inputs, ... }:
let
  # Static addresses live in the private repo so this one can stay public.
  net = (import "${inputs.nix-private}/hosts.nix").hothNet;
in {
  # Linux desktop VM (GNOME/Wayland) for testing GUI apps, e.g. the zeron
  # package before upstreaming it to nixpkgs. Networking mirrors jakku.
  imports = [
    ../../system/common.nix
    ./hardware.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = {
    "net.ipv6.conf.enp2s0.accept_ra" = 0;
    "net.ipv6.conf.enp2s0.addr_gen_mode" = 1;
    "net.ipv6.conf.enp2s0.use_tempaddr" = lib.mkForce 0;
  };

  networking = {
    hostName = "hoth";
    # GNOME pulls NetworkManager in by default; it would fight the static
    # scripted config below for enp2s0.
    networkmanager.enable = false;
    defaultGateway = net.gateway4;
    defaultGateway6 = {
      address = net.gateway6;
      interface = "enp2s0";
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    interfaces.enp2s0 = {
      ipv4.addresses = [{ address = net.address4; prefixLength = 24; }];
      ipv6.addresses = [{ address = net.address6; prefixLength = 64; }];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
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

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.${vars.user.name} = {
    isNormalUser = true;
    description = vars.user.fullname;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  # No programs.ssh.startAgent like jakku: GNOME already runs gcr-ssh-agent and
  # NixOS refuses two agents.
  programs.firefox.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;
  # Nix defaults to one job per vCPU (20 here); heavy C++ builds such as
  # onnxruntime take ~1 GB per job and OOM'd the 16 GB VM at that width.
  nix.settings.cores = 10;
  # Safety margin for build peaks (zeron's LTO link) instead of the OOM killer.
  zramSwap.enable = true;

  services.openssh.enable = true;

  security.sudo.extraRules = [{
    users = [ vars.user.name ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  system.stateVersion = "26.05";
}
