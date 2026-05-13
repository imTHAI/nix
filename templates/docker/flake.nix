{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
  let
    systems = [ "aarch64-darwin" "x86_64-linux" ];
    forAll  = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s});

    # ── À personnaliser ────────────────────────────────────────────────
    image    = "TON_USER/TON_IMAGE";
    workflow = "docker.yml";          # nom du fichier workflow GHA
    # ───────────────────────────────────────────────────────────────────

    mkApp = pkgs: script: {
      type    = "app";
      program = toString (pkgs.writeShellScript "app" script);
    };
  in {
    devShells = forAll (pkgs: {
      default = pkgs.mkShell {
        packages = [ pkgs.docker pkgs.gh ];
      };
    });

    apps = forAll (pkgs: {
      # Build arm64 natif + push :test — rapide, pour valider localement
      test = mkApp pkgs ''
        set -e
        docker build --platform linux/arm64 -t ${image}:test .
        docker push ${image}:test
        echo "✓ ${image}:test pushed"
      '';

      # git push + déclenche le workflow GHA (multi-arch :latest)
      ci = mkApp pkgs ''
        set -e
        git push
        gh workflow run ${workflow}
        echo "✓ Workflow ${workflow} déclenché"
      '';
    });
  };
}
