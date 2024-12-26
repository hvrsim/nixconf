{
  nixconf,
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
    # Install firefox.
    programs.firefox.enable = true;

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Activate security extensions.
    security.rtkit.enable = true;
    security.polkit.enable = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Configure keymap in X11.
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Install gnome extensions/themes.
    environment.systemPackages = with pkgs; [
      gnomeExtensions.blur-my-shell
      gnomeExtensions.user-themes
      gnomeExtensions.dash-to-dock
      gnomeExtensions.just-perfection
      gnome-tweaks
      whitesur-gtk-theme
      whitesur-icon-theme
      whitesur-cursors
    ];
  };
}
