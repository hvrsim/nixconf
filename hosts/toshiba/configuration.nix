{ nixconf, pkgs, ... }:

let
  inherit (builtins) attrValues;
in
{
  imports = attrValues nixconf.nixosModules;
  home-manager.sharedModules = attrValues nixconf.homeModules;

  modules = {
    gnome.enable = true;

    hardware = {
      microcode = true;
    };

    system = {
      hostName = "starship";
      username = "blazt";
      stateVersion = "23.05";
      plymouth = true;
    };
  };

  # Speed up boot process by removing network wait.
  networking.dhcpcd.wait = "background";
  systemd.services.NetworkManager-wait-online.enable = false;

  users.users.hassan = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
}
