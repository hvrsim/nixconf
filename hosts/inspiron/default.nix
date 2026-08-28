{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix

    ../../modules/core.nix
    ../../modules/laptop.nix
    ../../modules/omarchy.nix
    ../../modules/secureboot.nix
    ../../home
  ];

  time.timeZone = "America/Chicago";
  networking.hostName = "inspiron";

  boot.initrd.kernelModules = [ "amdgpu" ];

  omarchy = {
    enable = true;
    user = "yusuf";
    theme = "nord";
    wallpaper = "0-black-moon.jpg";
  };

  system.stateVersion = "26.05";
}
