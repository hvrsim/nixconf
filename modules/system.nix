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
    mkDefault
    singleton
    ;

  inherit (cfg)
    username
    ;

  cfg = config.modules.system;
in
{
  imports = with nixconf.inputs.home-manager.nixosModules; [ home-manager ];

  options.modules.system = {
    username = mkOption {
      type = str;
      default = "yusuf";
      description = "username for the main user";
    };

    stateVersion = mkOption {
      type = str;
      default = "24.11";
      description = "state version from original nixos install";
    };

    hostName = mkOption {
      type = str;
      default = "nixos";
      description = "system hostname";
    };
  };

  config = {
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

    documentation.nixos.includeAllModules = true;
  };
}
