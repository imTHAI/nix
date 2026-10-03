{ pkgs, config, ... }: {
  # Catppuccin Mocha everywhere Stylix knows how to reach. Set at the NixOS
  # level so GDM (the RDP Remote Login greeter) gets cursor and icons too; the
  # home-manager side inherits all of this through followSystem.
  # Per-app targets and the GNOME Shell layout live in home/hoth/gnome.nix.
  stylix = {
    enable = true;
    # Opt-in targets only: autoEnable also drops Blender/KDE/Qt theme files in
    # $HOME and fights hand-written configs (starship.toml). Copied to the
    # home-manager side by followSystem, which enables its own targets.
    autoEnable = false;
    targets = {
      gnome.enable         = true;
      gtk.enable           = true;
      font-packages.enable = true;
      fontconfig.enable    = true;
    };
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    # Explicit scheme above, so the wallpaper is only a background here and
    # is not fed to the palette generator.
    image = pkgs.nixos-artwork.wallpapers.catppuccin-mocha.gnomeFilePath;

    # The gnome target overlays gnome-shell to restyle GDM, which turns it and
    # everything built against it into local builds (no cache.nixos.org hit).
    # The greeter is on screen for two seconds per RDP login: not worth it.
    overlays.enable = false;

    cursor = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name    = "catppuccin-mocha-dark-cursors";
      size    = 24;
    };

    # WhiteSur is the macOS (Big Sur) icon set; Catppuccin only colours the
    # chrome around it.
    icons = {
      enable  = true;
      package = pkgs.whitesur-icon-theme;
      dark    = "WhiteSur-dark";
      light   = "WhiteSur-light";
    };

    # Inter is the closest free match to SF Pro. The mono font is the one the
    # starship prompt already relies on for its Nerd Font glyphs.
    fonts = {
      sansSerif = { package = pkgs.inter; name = "Inter"; };
      serif     = config.stylix.fonts.sansSerif;
      monospace = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; };
      emoji     = { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
      sizes = {
        applications = 11;
        desktop      = 11;
      };
    };
  };
}
