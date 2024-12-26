{ nixconf, pkgs, ... }:

let
  inherit (builtins) attrValues;
in
{
  imports = attrValues nixconf.nixosModules;
  home-manager.sharedModules = attrValues nixconf.homeModules;

  modules = {
    hardware.bluetooth = true;
    gnome.enable = true;

    system.hostName = "functional";
  };
}
