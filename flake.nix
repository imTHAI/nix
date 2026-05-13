{
  description = "Mon flake personnel — nix-darwin + nixos";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url   = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url     = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url    = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nur.url          = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nix-darwin, nixpkgs, mac-app-util, home-manager, sops-nix, nixos-wsl, ... }:
    let
      vars        = import ./vars.nix;
      specialArgs = { inherit inputs vars; };
    in
    {
      darwinConfigurations."kamino" = nix-darwin.lib.darwinSystem {
        specialArgs = specialArgs;
        modules = [
          ./hosts/kamino
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs        = true;
              useUserPackages      = true;
              backupFileExtension  = "before-hm";
              extraSpecialArgs     = specialArgs;
              users.${vars.user.name} = import ./home/kamino;
            };
          }
        ];
      };

      nixosConfigurations."tatooine" = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs;
        modules = [
          ./hosts/tatooine
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs       = true;
              useUserPackages     = true;
              backupFileExtension = "before-hm";
              extraSpecialArgs    = specialArgs;
              users.bcrevin = import ./home/tatooine;
            };
          }
        ];
      };

      nixosConfigurations."jakku" = nixpkgs.lib.nixosSystem {
        specialArgs = specialArgs;
        modules = [
          ./hosts/jakku
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            home-manager = {
              useGlobalPkgs        = true;
              useUserPackages      = true;
              backupFileExtension  = "before-hm";
              extraSpecialArgs     = specialArgs;
              users.${vars.user.name} = import ./home/jakku;
            };
          }
        ];
      };
    };
}
