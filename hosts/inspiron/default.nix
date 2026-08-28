{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../modules/core.nix
    ../../modules/laptop.nix
    ../../modules/secureboot.nix
    ../../home
  ];

  time.timeZone = "America/Chicago";
  networking.hostName = "inspiron";

  system.stateVersion = "26.05";
}
