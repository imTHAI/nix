{ pkgs, config, ... }:
let
  inherit (config.lib.stylix.colors) withHashtag;
in {
  # macOS-like GNOME layout: NixOS logo menu top-left, clock top-right,
  # floating dock at the bottom, traffic-light window buttons on the left.
  # Colours, fonts, cursor and icons come from Stylix (hosts/hoth/theme.nix).

  # stylix.autoEnable is off (hosts/hoth/theme.nix), so each target is opt-in.
  # Add terminal/editor targets here when such apps get installed.
  stylix.targets = {
    gnome.enable         = true;
    gtk.enable           = true;
    font-packages.enable = true;
    fontconfig.enable    = true;
  };

  programs.gnome-shell = {
    enable = true;
    # This list becomes org/gnome/shell/enabled-extensions and replaces it on
    # every activation. user-themes has to be listed even though Stylix
    # enables it itself (via an autostart entry), or each rebuild would drop
    # the Stylix shell theme until the next login.
    extensions = map (package: { inherit package; }) (with pkgs.gnomeExtensions; [
      user-themes
      dash-to-dock
      blur-my-shell
      just-perfection
      logo-menu
      rounded-window-corners-reborn
      appindicator
    ]);
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences".button-layout = "close,minimize,maximize:appmenu";

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      # Centered, content-sized dock instead of a full-width bar.
      extend-height = false;
      dock-fixed = false;
      intellihide = true;
      dash-max-icon-size = 48;
      running-indicator-style = "DOTS";
      custom-theme-shrink = true;
      # Low fixed opacity lets blur-my-shell's dock blur show through.
      transparency-mode = "FIXED";
      background-opacity = 0.4;
      show-trash = false;
      show-mounts = false;
      click-action = "minimize-or-previews";
    };

    "org/gnome/shell/extensions/just-perfection" = {
      # The logo menu takes over the top-left corner and links to the overview.
      activities-button = false;
      # 0 = center, 1 = right, 2 = left.
      clock-menu-position = 1;
      # 0 = desktop, 1 = overview.
      startup-status = 0;
    };

    "org/gnome/shell/extensions/Logo-menu" = {
      # Index into SymbolicDistroIcons in the extension's constants.js;
      # 23 is nixos-logo-symbolic.svg. Re-check after an extension bump.
      menu-button-icon-image = 23;
      menu-button-icon-size = 18;
    };
  };

  # Traffic-light window buttons. Stylix appends this to both gtk-3.0 and
  # gtk-4.0/gtk.css, so selectors cover libadwaita (windowcontrols, GTK4) and
  # adw-gtk3 (titlebutton, GTK3); each toolkit ignores the other's.
  stylix.targets.gtk.extraCss = ''
    windowcontrols > button > image {
      padding: 1px;
      -gtk-icon-size: 12px;
      color: transparent;
    }
    button.titlebutton {
      min-width: 14px;
      min-height: 14px;
      padding: 0;
      margin: 0 2px;
      color: transparent;
    }
    windowcontrols > button.close > image,
    button.titlebutton.close { background-color: ${withHashtag.base08}; }
    windowcontrols > button.minimize > image,
    button.titlebutton.minimize { background-color: ${withHashtag.base0A}; }
    windowcontrols > button.maximize > image,
    button.titlebutton.maximize { background-color: ${withHashtag.base0B}; }
    /* Glyphs only on hover, like macOS. */
    windowcontrols > button:hover > image,
    button.titlebutton:hover { color: rgba(0, 0, 0, 0.6); }
  '';
}
