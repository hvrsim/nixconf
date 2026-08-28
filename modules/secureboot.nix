{ lib, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.sbctl
  ];

  # Lanzaboote replaces the normal NixOS systemd-boot module.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 10;
  };
}
