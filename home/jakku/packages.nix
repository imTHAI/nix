{ pkgs }:

with pkgs;
let
  common = import ../common/packages.nix { inherit pkgs; };
in
common ++ [
  # age  # déchiffrement sops — décommenter après setup sops
]
