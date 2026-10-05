{ pkgs, ... }:
let
  catppuccin-kde = pkgs.catppuccin-kde.override {
    flavour      = [ "mocha" ];
    accents      = [ "mauve" ];
    # "modern" is the traffic-light decoration (round red/peach/green
    # buttons); "classic" uses flat Breeze-like glyphs.
    winDecStyles = [ "modern" ];
  };

  wallpaper = "${pkgs.nixos-artwork.wallpapers.catppuccin-mocha}/share/backgrounds/nixos/nixos-wallpaper-catppuccin-mocha.png";

  # Catppuccin Mocha terminal palette (values from catppuccin/konsole);
  # catppuccin-kde only ships the Plasma side.
  rgb = hex: let
    c = i: toString (builtins.fromTOML "v = 0x${builtins.substring i 2 hex}").v;
  in "${c 0},${c 2},${c 4}";
  konsoleColor = hex: { Color = rgb hex; };
  catppuccinMochaKonsole = {
    General = {
      Description = "Catppuccin Mocha";
      # Translucent window; KWin's blur effect frosts what shows through.
      Opacity = 0.9;
      Blur = true;
    };
    Background          = konsoleColor "1e1e2e";
    BackgroundIntense   = konsoleColor "1e1e2e";
    BackgroundFaint     = konsoleColor "1e1e2e";
    Foreground          = konsoleColor "cdd6f4";
    ForegroundIntense   = konsoleColor "cdd6f4";
    ForegroundFaint     = konsoleColor "cdd6f4";
    Color0              = konsoleColor "45475a";
    Color0Intense       = konsoleColor "585b70";
    Color0Faint         = konsoleColor "45475a";
    Color1              = konsoleColor "f38ba8";
    Color1Intense       = konsoleColor "f38ba8";
    Color1Faint         = konsoleColor "f38ba8";
    Color2              = konsoleColor "a6e3a1";
    Color2Intense       = konsoleColor "a6e3a1";
    Color2Faint         = konsoleColor "a6e3a1";
    Color3              = konsoleColor "f9e2af";
    Color3Intense       = konsoleColor "f9e2af";
    Color3Faint         = konsoleColor "f9e2af";
    Color4              = konsoleColor "89b4fa";
    Color4Intense       = konsoleColor "89b4fa";
    Color4Faint         = konsoleColor "89b4fa";
    Color5              = konsoleColor "f5c2e7";
    Color5Intense       = konsoleColor "f5c2e7";
    Color5Faint         = konsoleColor "f5c2e7";
    Color6              = konsoleColor "94e2d5";
    Color6Intense       = konsoleColor "94e2d5";
    Color6Faint         = konsoleColor "94e2d5";
    Color7              = konsoleColor "bac2de";
    Color7Intense       = konsoleColor "a6adc8";
    Color7Faint         = konsoleColor "bac2de";
  };

  # krdp only autogenerates a throwaway certificate when none is given, so
  # every restart would show the client a new fingerprint. Generate one
  # long-lived self-signed pair on first start and keep it.
  krdpCert = pkgs.writeShellScript "krdp-ensure-cert" ''
    dir="$HOME/.local/share/krdpserver"
    [ -s "$dir/krdp.crt" ] && [ -s "$dir/krdp.key" ] && exit 0
    mkdir -p "$dir"
    ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:3072 -nodes -days 3650 \
      -subj "/CN=hoth" -keyout "$dir/krdp.key" -out "$dir/krdp.crt"
    chmod 600 "$dir/krdp.key"
  '';
in {
  # macOS-like Plasma: menu bar on top (NixOS logo menu, global app menu,
  # tray, clock), floating auto-hiding dock at the bottom, traffic-light
  # buttons on the left of each title bar, magic-lamp minimize.
  # Catppuccin Mocha / Mauve throughout; GTK apps get the same palette
  # through Stylix (hosts/hoth/theme.nix).

  # stylix.autoEnable is off (hosts/hoth/theme.nix), so each target is opt-in.
  # No kde target on purpose: plasma-manager owns kdeglobals/kwinrc below.
  stylix.targets = {
    gtk.enable           = true;
    font-packages.enable = true;
    fontconfig.enable    = true;
  };

  home.packages = [ catppuccin-kde ];

  programs.plasma = {
    enable = true;

    workspace = {
      colorScheme = "CatppuccinMochaMauve";
      iconTheme   = "WhiteSur-dark";
      cursor = {
        theme = "catppuccin-mocha-dark-cursors";
        size  = 24;
      };
      windowDecorations = {
        library = "org.kde.kwin.aurorae";
        theme   = "__aurorae__svg__CatppuccinMocha-Modern";
      };
      splashScreen.theme = "Catppuccin-Mocha-Mauve";
      inherit wallpaper;
    };

    fonts = {
      general     = { family = "Inter"; pointSize = 10; };
      menu        = { family = "Inter"; pointSize = 10; };
      toolbar     = { family = "Inter"; pointSize = 10; };
      windowTitle = { family = "Inter"; pointSize = 10; };
      small       = { family = "Inter"; pointSize = 8; };
      fixedWidth  = { family = "JetBrainsMono Nerd Font"; pointSize = 10; };
    };

    input.keyboard.layouts = [{ layout = "us"; variant = "mac"; }];

    kwin = {
      titlebarButtons = {
        left  = [ "close" "minimize" "maximize" ];
        right = [ ];
      };
      effects = {
        blur.enable = true;
        minimization.animation = "magiclamp";
      };
    };

    panels = [
      # Menu bar. Not floating: the macOS bar is flush with the screen edge.
      {
        location = "top";
        height   = 28;
        floating = false;
        widgets = [
          # nix-snowflake-white comes from nixos-icons, already on the system.
          { kickoff = { icon = "nix-snowflake-white"; }; }
          "org.kde.plasma.appmenu"
          { panelSpacer = { expanding = true; }; }
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
      # Dock: content-sized, floating, steps aside when a window overlaps it.
      {
        location   = "bottom";
        height     = 56;
        floating   = true;
        alignment  = "center";
        lengthMode = "fit";
        hiding     = "dodgewindows";
        widgets = [
          # Full-screen app grid, the closest thing to Launchpad. Its default
          # start-here icon is an Apple logo in WhiteSur.
          { kickerdash.icon = "applications-all"; }
          {
            iconTasks.launchers = [
              "applications:org.kde.dolphin.desktop"
              "applications:firefox.desktop"
              "applications:org.kde.konsole.desktop"
              "applications:org.kde.kate.desktop"
              "applications:systemsettings.desktop"
            ];
          }
        ];
      }
    ];

    # Remote-only VM: a lock screen or a blanked/suspended display just
    # breaks the next RDP connection.
    kscreenlocker = {
      autoLock      = false;
      lockOnResume  = false;
    };
    powerdevil.AC = {
      autoSuspend.action          = "nothing";
      turnOffDisplay.idleTimeout  = "never";
      dimDisplay.enable           = false;
    };

    # QXL's mode list stops at 2560x1600, which letterboxes on kamino's
    # 2560x1440 displays. krdp streams whatever the output is set to and
    # ignores client resize requests, so pin the output to the client size.
    # kscreen remembers it afterwards; this only acts on a fresh profile.
    startup.startupScript.rdp-resolution = {
      runAlways = true;
      text = ''
        kd=${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor
        outputs() { "$kd" -o | sed 's/\x1b\[[0-9;]*m//g'; }
        outputs | grep -q "Geometry: 0,0 2560x1440" && exit 0
        outputs | grep -q "2560x1440@" || "$kd" output.1.addCustomMode.2560.1440.60000.full
        mode=$(outputs | tr ' ' '\n' | grep -m1 '2560x1440@' | cut -d: -f1)
        [ -n "$mode" ] && "$kd" output.1.mode."$mode"
      '';
    };

    configFile = {
      # kde-rounded-corners (installed system-wide, see hosts/hoth) rounds
      # all four window corners; aurorae only rounds the title bar.
      kwinrc.Plugins.kwin4_effect_shapecornersEnabled = true;
      # Log in with the hoth account password (PAM) instead of a separate
      # krdp user whose password would live in KWallet, which an autologin
      # session never unlocks.
      krdpserverrc.General = {
        SystemUserEnabled = true;
        # Started by the unit below; the KCM toggle would start a second copy.
        Autostart = false;
      };
    };
  };

  # krdp's own unit runs it through the XDG portal, which pops a consent
  # dialog nobody can click on a headless VM. --plasma talks to KWin's
  # privileged screencast/fake-input protocols instead (krdp's .desktop file
  # grants them). It shares the running session's screen, which is why
  # hosts/hoth enables SDDM autologin.
  programs.konsole = {
    enable = true;
    customColorSchemes.CatppuccinMocha = catppuccinMochaKonsole;
    defaultProfile = "Catppuccin";
    profiles.Catppuccin = {
      colorScheme = "CatppuccinMocha";
      font = { name = "JetBrainsMono Nerd Font"; size = 11; };
    };
  };

  systemd.user.services.krdpserver = {
    Unit = {
      Description = "KRdp server sharing the Plasma session over RDP";
      After  = [ "plasma-core.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStartPre = "${krdpCert}";
      ExecStart = "${pkgs.kdePackages.krdp}/bin/krdpserver --plasma"
        + " --certificate %h/.local/share/krdpserver/krdp.crt"
        + " --certificate-key %h/.local/share/krdpserver/krdp.key";
      Restart    = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "plasma-workspace.target" ];
  };
}
