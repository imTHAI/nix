{ pkgs }:

with pkgs;
let
  common = import ../common/packages.nix { inherit pkgs; };
in
common ++ [
  vivid    # générateur LS_COLORS dynamique
rsyncy   # rsync avec progress bar
  aria2    # téléchargement multi-connexions
  ffmpeg   # conversion audio/vidéo
  nodejs   # requis par le plugin claude-mem (hooks Stop/PostToolUse)
  bun      # requis par le plugin claude-mem (worker bun-runner.js, depuis 13.24.x)
  zellij   # multiplexeur terminal
  ocrmypdf # OCR de PDF scannés (couche de texte invisible, cherchable par Spotlight)
]
