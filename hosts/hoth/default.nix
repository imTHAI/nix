{ pkgs, lib, vars, inputs, ... }:
let
  # Static addresses live in the private repo so this one can stay public.
  net = (import "${inputs.nix-private}/hosts.nix").hothNet;
in {
  # Linux desktop VM (KDE Plasma 6/Wayland) for testing GUI apps, e.g. the zeron
  # package before upstreaming it to nixpkgs. Networking mirrors jakku.
  imports = [
    ../../system/common.nix
    ./hardware.nix
    ./theme.nix
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
    # NetworkManager would fight the static scripted config below for enp2s0.
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
      # 3389: krdp (user service, see home/hoth/plasma.nix).
      allowedTCPPorts = [ 22 3389 ];
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

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  # krdp can only share a session that is already running (no GDM-style
  # Remote Login in Plasma 6.7), and the VM has no one at the console:
  # log straight into Plasma so the RDP server is up after every boot.
  services.displayManager.autoLogin = {
    enable = true;
    user = vars.user.name;
  };
  # SDDM and the TTYs read this; Plasma has its own copy in kxkbrc.
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
  programs.ssh.startAgent = true;
  programs.firefox.enable = true;
  # KWin effect plugin: system profile so it lands on KWin's QT_PLUGIN_PATH.
  # Enabled from home/hoth/plasma.nix.
  environment.systemPackages = [ pkgs.kde-rounded-corners ];

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

  # FreeRDP 3.32.x server regression: Windows App (macOS) stalls at "Securing
  # connection" after NLA (HYBRID_EX path), see FreeRDP/FreeRDP#13583. It is
  # in libfreerdp-server, so krdp inherits it just like gnome-remote-desktop
  # did. Pin only krdp's FreeRDP to 3.31.1; drop once nixpkgs ships a fix.
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (kfinal: kprev: {
        krdp = kprev.krdp.override {
          freerdp = prev.freerdp.overrideAttrs (old: {
            version = "3.31.1";
            src = prev.fetchFromGitHub {
              owner = "FreeRDP";
              repo = "FreeRDP";
              tag = "3.31.1";
              hash = "sha256-6/YMQLcgOogoXu3Lhwl+g3+Ov59t4x7oOFlVLCa8+RU=";
            };
          });
        };
      });
    })
  ];

  security.sudo.extraRules = [{
    users = [ vars.user.name ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];

  system.stateVersion = "26.05";
}
