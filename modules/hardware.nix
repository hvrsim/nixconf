{
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
    microcode
    ;

  cfg = config.modules.hardware;
in
{
  options.modules.hardware = {
    bluetooth = mkEnableOption "bluetooth support";
    microcode = mkEnableOption "CPU microcode updates";
  };

  config = {
    hardware.bluetooth.enable = mkIf bluetooth true;
    hardware.cpu.intel.updateMicrocode = mkIf microcode true;
    hardware.cpu.amd.updateMicrocode = mkIf microcode true;
  };
}
