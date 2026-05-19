{ pkgs, lib, ... }: {

  home.activation.calibreConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/Library/Preferences/calibre/plugins"
  '';

  # herdr has no nixpkg — fetch the prebuilt binary from GitHub releases if absent.
  home.activation.installHerdr = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.local/bin/herdr" ]; then
      mkdir -p "$HOME/.local/bin"
      ${pkgs.curl}/bin/curl -fsSL \
        "https://github.com/ogulcancelik/herdr/releases/latest/download/herdr-darwin-aarch64" \
        -o "$HOME/.local/bin/herdr"
      chmod +x "$HOME/.local/bin/herdr"
    fi
  '';
  home.packages = pkgs.callPackage ./packages.nix { };

  xdg.configFile."alacritty/alacritty.toml".text = ''
    [font]
    size = 15

    [font.normal]
    family = "JetBrainsMono Nerd Font"
    style = "Regular"

    [font.bold]
    family = "JetBrainsMono Nerd Font"
    style = "Bold"

    [font.italic]
    family = "JetBrainsMono Nerd Font"
    style = "Italic"
  '';

  xdg.configFile."ghostty/config".text = ''
    background = 000000
    theme = TokyoNight
    font-family = JetBrainsMono Nerd Font
    font-size = 15
    copy-on-select = true
    macos-option-as-alt = false
    working-directory = home
  '';

  xdg.configFile."mc/ini".source       = ./mc-ini;
  xdg.configFile."mc/panels.ini".source = ./mc-panels.ini;
  xdg.configFile."mc/hotlist".text = ''
    ENTRY "Kindle"             URL "/Volumes/Kindle"
    ENTRY "downloads"          URL "/Users/pbear/downloads"
    ENTRY "media"              URL "/Volumes/media"
    ENTRY "downloads-UNRAID"   URL "/Users/pbear/downloads_unraid"
    ENTRY "dl-unraid via SCP"  URL "sh://root@10.0.0.2/mnt/user/downloads"
    ENTRY "iCloudDrive"        URL "/Users/pbear/Library/Mobile Documents/com~apple~CloudDocs/"
    ENTRY "UDM via SCP"        URL "sh://root@192.168.0.1/root"
  '';

  xdg.configFile."nano/nanorc".text = ''
    include "${pkgs.nano}/share/nano/*.nanorc"
    include "${pkgs.nano}/share/nano/extra/*.nanorc"
  '';

  programs.gh = {
    enable = true;
    settings = {
      version      = 1;
      git_protocol = "https";
      prompt       = "enabled";
      aliases.co   = "pr checkout";
      spinner      = "enabled";
    };
  };

  xdg.configFile."gh-dash/config.yml".source = ./gh-dash-config.yml;
}
