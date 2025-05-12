{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (lib.types) str bool;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    ;

  inherit (cfg)
    bluetooth
    enable
    splash
    splashTheme
    tmpfs
    ;

  cfg = config.modules.laptop;
in
{
  options.modules.laptop = {
    enable = mkEnableOption "configuration for laptops";

    bluetooth = mkOption {
      type = bool;
      default = true;
      description = "bluetooth support";
    };

    splash = mkOption {
      type = bool;
      default = true;
      description = "plymouth boot splash";
    };

    splashTheme = mkOption {
      type = str;
      default = "blockchain";
      description = "animation for plymouth boot splash";
    };

    tmpfs = mkOption {
      type = bool;
      default = true;
      description = "tmpfs mounted on /tmp";
    };
  };

  config = mkIf enable {
    services.fwupd.enable = true;
    services.thermald.enable = true;
    services.upower.enable = true;

    hardware.bluetooth = mkIf bluetooth {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    boot = {
      tmp = {
        useTmpfs = tmpfs;
        cleanOnBoot = !tmpfs;
      };

      plymouth = mkIf splash {
        enable = true;
        theme = "blockchain";
        themePackages = with pkgs; [
          # By default we would install all themes
          (adi1090x-plymouth-themes.override {
            selected_themes = [ splashTheme ];
          })
        ];
      };

      loader = {
        systemd-boot = mkIf (pkgs.system != "aarch64-linux") {
          enable = true;
          configurationLimit = 10;
        };

        efi.canTouchEfiVariables = true;
        timeout = 0;
      };

      # Enable "Silent Boot"
      consoleLogLevel = mkIf splash 0;
      initrd.verbose = mkIf splash false;
      kernelParams = mkIf splash [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };

    # disable NMI watchdog (not needed on laptops)
    boot.kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
    };

    hardware.cpu = {
      intel.updateMicrocode = true;
      amd.updateMicrocode = true;
    };

    # enable power management with powertop daemon
    powerManagement.powertop.enable = true;
  };
}
