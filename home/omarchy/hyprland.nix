{
  omarchyPath,
  ...
}:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";

    # UWSM owns graphical-session.target and the session environment.
    systemd.enable = false;
    extraConfig = ''
      _G.omarchy_default_bindings = false
      dofile("${omarchyPath}/config/hypr/hyprland.lua")
    '';
  };

  xdg.configFile = {
    "hypr/autostart.lua".source = "${omarchyPath}/config/nix/hypr/autostart.lua";
    "hypr/bindings.lua".source = "${omarchyPath}/config/nix/hypr/bindings.lua";
    "hypr/hyprsunset.conf".source = "${omarchyPath}/config/hypr/hyprsunset.conf";
    "hypr/input.lua".source = "${omarchyPath}/config/nix/hypr/input.lua";
    "hypr/looknfeel.lua".source = "${omarchyPath}/config/hypr/looknfeel.lua";
    "hypr/monitors.lua".source = "${omarchyPath}/config/hypr/monitors.lua";
    "hypr/xdph.conf".source = "${omarchyPath}/config/hypr/xdph.conf";
  };
}
