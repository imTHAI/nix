{ inputs, ... }: {
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.nur.overlays.default ];
}
