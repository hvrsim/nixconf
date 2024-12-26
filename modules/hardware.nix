{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  inherit (cfg)
    bluetooth
    ;

  cfg = config.modules.hardware;
in
{
  options.modules.hardware = {
    bluetooth = mkEnableOption "bluetooth support";
  };

  config = {
    hardware.bluetooth.enable = mkIf bluetooth true;
  };
}
