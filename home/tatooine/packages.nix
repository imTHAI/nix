{ pkgs }:

with pkgs;
let
  common = import ../common/packages.nix { inherit pkgs; };
in
common ++ [
  # packages spécifiques tatooine
]
