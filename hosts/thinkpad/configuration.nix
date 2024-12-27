{ nixconf, pkgs, ... }:

let
  inherit (builtins) attrValues;
in
{
  imports =
    attrValues nixconf.nixosModules
    ++ [ nixconf.inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x250 ]
    ++ [ nixconf.inputs.chaotic.nixosModules.default ];
  home-manager.sharedModules = attrValues nixconf.homeModules;

  # use the CachyOS kernel.
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  modules = {
    gnome.enable = true;

    hardware = {
      bluetooth = true;
      microcode = true;
    };

    system = {
      hostName = "functional";
      plymouth = true;
    };
  };
}
