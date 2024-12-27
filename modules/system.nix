{
  nixconf,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib.types) str;

  inherit (lib)
    mkOption
    mkEnableOption
    mkDefault
    mkIf
    singleton
    ;

  inherit (cfg)
    username
    iHaveLotsOfRam
    plymouth
    ;

  cfg = config.modules.system;
in
{
  imports = with nixconf.inputs.home-manager.nixosModules; [ home-manager ];

  options.modules.system = {
    username = mkOption {
      type = str;
      default = "yusuf";
    };

    timeZone = mkOption {
      type = str;
      default = "America/Chicago";
    };

    defaultLocale = mkOption {
      type = str;
      default = "en_US.UTF-8";
    };

    stateVersion = mkOption {
      type = str;
      default = "24.11";
    };

    hostName = mkOption {
      type = str;
      default = "nixos";
    };

    iHaveLotsOfRam = mkEnableOption "tmpfs on /tmp";
    plymouth = mkEnableOption "plymouth boot animations";
  };

  config = {
    boot =
      if plymouth then
        {
          tmp = if iHaveLotsOfRam then { useTmpfs = true; } else { cleanOnBoot = true; };

          plymouth = {
            enable = true;
            theme = "cuts";
            themePackages = with pkgs; [
              # By default we would install all themes
              (adi1090x-plymouth-themes.override {
                selected_themes = [ "cuts" ];
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
          consoleLogLevel = 0;
          initrd.verbose = false;
          kernelParams = [
            "quiet"
            "splash"
            "boot.shell_on_fail"
            "loglevel=3"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
          ];
        }
      else
        {
          tmp = if iHaveLotsOfRam then { useTmpfs = true; } else { cleanOnBoot = true; };

          loader = {
            systemd-boot = mkIf (pkgs.system != "aarch64-linux") {
              enable = true;
              configurationLimit = 10;
            };

            efi.canTouchEfiVariables = true;
            timeout = 0;
          };
        };

    nix = {
      package = pkgs.nixVersions.latest;

      gc = {
        automatic = mkDefault true;
        dates = mkDefault "weekly";
        options = mkDefault "--delete-older-than 7d";
      };

      settings = {
        auto-optimise-store = true;
        warn-dirty = false;

        experimental-features = [
          "nix-command"
          "flakes"
        ];

        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };

    zramSwap.enable = true;

    time = {
      inherit (cfg) timeZone;
    };

    i18n = {
      inherit (cfg) defaultLocale;
    };

    system = {
      inherit (cfg) stateVersion;
    };

    users.users.${username} = {
      isNormalUser = true;
      description = username;
      uid = 1000;

      extraGroups = [
        "networkmanager"
        "wheel"
        "kvm"
        "video"
        "input"
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      sharedModules = singleton {
        home = {
          inherit (cfg) stateVersion;
        };

        programs.man.generateCaches = true;
      };

      users.${username}.home = {
        inherit username;

        homeDirectory = "/home/${username}";
      };
    };

    networking = {
      inherit (cfg) hostName;

      networkmanager.enable = true;
    };
  };
}
