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

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  modules = {
    gnome.enable = true;
    laptop.enable = true;

    system.hostName = "functional";
  };
}
