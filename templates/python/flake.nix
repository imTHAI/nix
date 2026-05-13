{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
  let
    systems    = [ "aarch64-darwin" "x86_64-linux" "x86_64-darwin" "aarch64-linux" ];
    forAll     = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});
  in {
    devShells = forAll (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          python314
          uv       # gestionnaire de paquets et envs virtuels
          ruff     # linter + formatter
          pyright  # LSP (autocomplétion, types)
        ];
      };
    });
  };
}
