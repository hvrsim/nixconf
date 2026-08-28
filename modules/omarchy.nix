{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.omarchy;
  omarchyPackage = pkgs.callPackage ../packages/omarchy {
    theme = cfg.theme;
    wallpaper = cfg.wallpaper;
  };
  hyprlandSession = {
    command = "${pkgs.uwsm}/bin/uwsm start hyprland.desktop";
    user = cfg.user;
  };
in
{
  options.omarchy = {
    enable = lib.mkEnableOption "omarchy profile";

    user = lib.mkOption {
      type = lib.types.str;
      example = "yusuf";
      description = "Existing NixOS user that owns the Omarchy desktop session.";
    };

    autoLogin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether greetd starts the Omarchy session after boot.";
    };

    theme = lib.mkOption {
      type = lib.types.enum (import ../lib/omarchy-themes.nix);
      default = "nord";
      example = "nord";
      description = "Omarchy theme shared by Plymouth, Hyprland, Foot, and the shell.";
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.strMatching "^[A-Za-z0-9][A-Za-z0-9._+-]*[.](jpg|jpeg|png|gif|bmp|webp)$"
      );
      default = null;
      example = "0-black-moon.jpg";
      description = ''
        Default wallpaper filename from the selected Omarchy theme. When null,
        the first wallpaper is used. The live picker may change this at runtime.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.user config.users.users;
        message = "omarchy.user must name an existing NixOS user";
      }
    ];

    boot = {
      loader.timeout = 0;
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "systemd.show_status=false"
        "rd.systemd.show_status=false"
        "udev.log_level=3"
        "vt.global_cursor_default=0"
      ];

      # Plymouth owns the graphical disk-unlock prompt and boot transition.
      plymouth = {
        enable = true;
        theme = "omarchy";
        themePackages = [ omarchyPackage ];
      };
    };

    programs = {
      dconf.enable = true;
      hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    security = {
      pam.services = {
        # Omarchy's Quickshell lock intentionally runs password and fingerprint
        # in separate PAM contexts so neither method blocks the other.
        omarchy-lock-password.fprintAuth = false;
        omarchy-lock-fingerprint = {
          fprintAuth = true;
          unixAuth = false;
        };
        sudo.fprintAuth = true;
        polkit-1.fprintAuth = true;
      };
      polkit.enable = true;
      rtkit.enable = true;
    };

    services = {
      dbus.packages = [ pkgs.gcr ];
      gvfs.enable = true;
      tumbler.enable = true;
      udisks2.enable = true;
      gnome.gnome-keyring.enable = true;

      greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd '${hyprlandSession.command}'";
            user = "greeter";
          };
        }
        // lib.optionalAttrs cfg.autoLogin {
          initial_session = hyprlandSession;
        };
      };

      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      fprintd.enable = true;
    };

    fonts = {
      packages = with pkgs; [
        font-awesome
        nerd-fonts.jetbrains-mono
        noto-fonts
        noto-fonts-color-emoji
      ];
      fontconfig.defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    # All user-session state lives with this profile. Removing `enable = true`
    # removes the graphical session without touching the reusable base home.
    home-manager.extraSpecialArgs = { inherit omarchyPackage; };
    home-manager.users.${cfg.user}.imports = [ ../home/omarchy ];
  };
}
