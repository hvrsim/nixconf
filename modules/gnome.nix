{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  inherit (cfg)
    enable
    ;

  cfg = config.modules.gnome;
in
{
  options.modules.gnome = {
    enable = mkEnableOption "use gnome as the desktop enviorment";
  };

  config = mkIf enable {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    environment = {
      systemPackages = with pkgs; [
        gnomeExtensions.blur-my-shell
        gnomeExtensions.user-themes
        gnomeExtensions.dash-to-dock
        gnomeExtensions.just-perfection
        gnome-tweaks
        whitesur-gtk-theme
        whitesur-icon-theme
        whitesur-cursors
      ];

      gnome.excludePackages = with pkgs; [
        gnome-tour
        gnome-contacts
        gnome-weather
        geary
      ];
    };
  };
}
