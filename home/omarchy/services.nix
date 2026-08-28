{
  config,
  lib,
  omarchyPath,
  osConfig,
  pkgs,
  ...
}:

let
  wallpaperDeclaration = "${osConfig.omarchy.theme}:${
    if osConfig.omarchy.wallpaper == null then "default" else osConfig.omarchy.wallpaper
  }";
  wallpaperInit = pkgs.writeShellApplication {
    name = "omarchy-wallpaper-init";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/current"
      background_link="$state_dir/background"
      declaration_file="$state_dir/wallpaper.declaration"
      declared_background="$(${pkgs.coreutils}/bin/readlink -f ${omarchyPath}/current-background)"

      mkdir -p "$state_dir"
      previous_declaration=""
      if [[ -f "$declaration_file" ]]; then
        previous_declaration=$(<"$declaration_file")
      fi

      if [[ ! -e "$background_link" || "$previous_declaration" != ${lib.escapeShellArg wallpaperDeclaration} ]]; then
        ln -sfn "$declared_background" "$background_link"
      fi

      printf '%s\n' ${lib.escapeShellArg wallpaperDeclaration} > "$declaration_file"
    '';
  };
in
{
  home.file = {
    ".local/state/omarchy/current/theme".source = "${omarchyPath}/current-theme";
    ".local/state/omarchy/current/theme.name".text = "${osConfig.omarchy.theme}\n";
  };

  xdg.configFile."omarchy/shell.json".source = "${omarchyPath}/config/nix/shell.json";

  services = {
    blueman-applet.enable = true;
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "omarchy-system-wake";
          before_sleep_cmd = "omarchy-system-lock";
          ignore_dbus_inhibit = false;
          lock_cmd = "omarchy-system-lock";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "omarchy-system-lock";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
    hyprpolkitagent.enable = true;
    network-manager-applet.enable = true;
    swayosd.enable = true;
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "never";
    };
  };

  systemd.user.services = {
    omarchy-shell = {
      Unit = {
        Description = "Omarchy desktop shell and status bar";
        After = [
          "graphical-session-pre.target"
          "omarchy-wallpaper-init.service"
        ];
        Requires = [ "omarchy-wallpaper-init.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.quickshell}/bin/quickshell -n -p ${omarchyPath}/shell";
        Restart = "on-failure";
        RestartSec = 1;
        Environment = [
          "QS_DISABLE_FILE_WATCHER=1"
          "QS_NO_RELOAD_POPUP=1"
          "QT_PLUGIN_PATH=${pkgs.qt6.qtimageformats}/lib/qt-6/plugins"
        ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    omarchy-wallpaper-init = {
      Unit = {
        Description = "Initialize Omarchy wallpaper state";
        Before = [ "omarchy-shell.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${wallpaperInit}/bin/omarchy-wallpaper-init";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
