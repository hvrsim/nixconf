{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../modules/core.nix
    ../../modules/boot.nix
    ../../modules/laptop.nix
    ../../modules/secureboot.nix
    ../../home
  ];

  time.timeZone = "America/Chicago";
  networking.hostName = "inspiron";

  boot.plymouth.omarchyTheme = "nord";

  system.stateVersion = "26.05";
}
