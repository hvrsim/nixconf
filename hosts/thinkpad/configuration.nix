{ nixconf, pkgs, ... }:

let
  inherit (builtins) attrValues;
in
{
  imports = attrValues nixconf.nixosModules ++ [nixconf.inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x250];
  home-manager.sharedModules = attrValues nixconf.homeModules;

  # enable microcode updates.
  hardware.cpu.intel.updateMicrocode = true;

  modules = {
    hardware.bluetooth = true;
    gnome.enable = true;

    system.hostName = "functional";
  };
}
