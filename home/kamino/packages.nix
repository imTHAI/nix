{ pkgs }:

with pkgs;
let
  common = import ../common/packages.nix { inherit pkgs; };
in
common ++ [
  vivid    # générateur LS_COLORS dynamique
  starship # prompt
  rsyncy   # rsync avec progress bar
  aria2    # téléchargement multi-connexions
  ffmpeg   # conversion audio/vidéo
  nodejs      # requis par le plugin claude-mem (hooks Stop/PostToolUse)
  ghostty-bin # terminal emulator (prebuilt, darwin universal)
]
