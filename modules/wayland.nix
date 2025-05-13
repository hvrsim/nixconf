{
  config,
  lib,
  ...
}:

let
  inherit (lib.types) bool;

  inherit (lib)
    mkIf
    mkOption
    ;

  inherit (cfg)
    enable
    ;

  cfg = config.modules.wayland;
in
{
  options.modules.wayland = {
    enable = mkOption {
      type = bool;
      default = config.modules.gnome.enable;
      description = "wayland desktop protocol";
    };
  };

  config = mkIf enable {
    services.xserver.enable = true;
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    security = {
      polkit.enable = true;
      rtkit.enable = true;
      pam.services = {
        "sudo".fprintAuth = true;
        "su".fprintAuth = true;
      };
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
