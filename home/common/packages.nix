{ pkgs }:

with pkgs;
[
  neovim
  rsync
  python314
  macchina
  dig
  mc
  yt-dlp
  nerd-fonts.jetbrains-mono
  htop
  xz
  uv
  mediainfo
  gh
  gh-dash
  direnv
  sops    # éditer secrets chiffrés
  age     # backend de chiffrement utilisé par sops
]
