{ pkgs, config, ... }: {
  # Catppuccin Mocha for everything outside Plasma: GTK apps (Firefox, etc.),
  # fonts, cursor. Plasma itself is themed by plasma-manager with the
  # upstream Catppuccin KDE port (home/hoth/plasma.nix), which matches the
  # palette exactly instead of going through Stylix's base16 mapping.
  # The home-manager side inherits all of this through followSystem.
  stylix = {
    enable = true;
    # Opt-in targets only: autoEnable also drops Blender/KDE/Qt theme files in
    # $HOME and fights hand-written configs (starship.toml), and its kde target
    # would race plasma-manager for the same kdeglobals keys.
    autoEnable = false;
    targets = {
      gtk.enable           = true;
      font-packages.enable = true;
      fontconfig.enable    = true;
    };
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    cursor = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name    = "catppuccin-mocha-dark-cursors";
      size    = 24;
    };

    # WhiteSur is the macOS (Big Sur) icon set; set here for GTK apps, and
    # again for Plasma in home/hoth/plasma.nix.
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
        applications = 10;
        desktop      = 10;
      };
    };
  };
}
