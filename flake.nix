{
  description = "hvrsim's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
        url = "github:nix-community/nixvim";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }:
  let
    inherit (nixpkgs.lib) nixosSystem genAttrs replaceStrings;
    inherit (nixpkgs.lib.filesystem) listFilesRecursive;

    nameOf = path: replaceStrings [ ".nix" ] [ "" ] (baseNameOf (toString path));
  in
  {
    nixosModules = genAttrs (map nameOf (listFilesRecursive ./modules)) (
      name: import ./modules/${name}.nix
    );

    homeModules = genAttrs (map nameOf (listFilesRecursive ./home)) (name: import ./home/${name}.nix);

    nixosConfigurations = {
      thinkpad = nixosSystem {
        system = "x86_64-linux";
        specialArgs.nixconf = self;
        modules = listFilesRecursive ./hosts/thinkpad;
      };
    };

    formatter = nixpkgs.nixfmt-style-rfc;
  };
}
