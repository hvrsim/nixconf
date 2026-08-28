{
  description = "hvrsim's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      disko,
      lanzaboote,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosModules = {
        default = ./modules/omarchy.nix;
        omarchy = ./modules/omarchy.nix;
      };

      nixosConfigurations.inspiron = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/inspiron

          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
        ];
      };

      packages.${system}.omarchy = pkgs.callPackage ./packages/omarchy { };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
