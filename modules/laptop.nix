{
  services.fwupd.enable = true;
  services.upower.enable = true;
  services.fstrim.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.tmp.useTmpfs = true;

  networking.networkmanager.enable = true;
  powerManagement.enable = true;

  # Inspiron 7415 2-in-1 orientation / ambient-light sensor support.
  hardware.sensor.iio.enable = true;
}
