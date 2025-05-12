{ nixconf, ... }:

let
  inherit (builtins) attrValues;
in
{
  imports = attrValues nixconf.nixosModules;
  home-manager.sharedModules = attrValues nixconf.homeModules;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  modules = {
    gnome.enable = true;
    laptop = {
      enable = true;
      bluetooth = false;
      tmpfs = false;
    };

    system = {
      hostName = "starship";
      username = "blazt";
      stateVersion = "23.05";
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
